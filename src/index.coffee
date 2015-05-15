# load express
express = require 'express'
app = express()

# require modules
request = require 'request'
requestDebug = require 'request-debug'
Busboy = require 'busboy'
url = require 'url'
uuid = require 'uuid'
mhd2xds = require './mhd2xds'

# get config objects
config = require "../config/config"
apiConfig = config.api
mediatorConfig = require "../config/mediator"

# include register script
register = require "./register"
if config.registration.enabled
  register.registerMediator apiConfig, mediatorConfig

requestDataMap = {}
requestDebug request, (type, data, r) ->
  if type is 'request'
    requestDataMap[data.headers['mhd-correlation-id']] = data

##### Default Endpoint  #####
app.post '*', (req, res) ->

  console.log 'Recieved request...'

  busboy = new Busboy headers: req.headers

  contentBufs = []
  metadataBufs = []
  metadata = null

  busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
    if fieldname is 'ihe-mhd-metadata'
      file.on 'data', (chunk) ->
        metadataBufs.push chunk
      file.on 'end', ->
        metadata = JSON.parse(Buffer.concat(metadataBufs))

    if fieldname is 'content'
      file.on 'data', (chunk) ->
        contentBufs.push chunk

  busboy.on 'finish', ->
    console.log 'Finished parsing attachments...'

    cda = (Buffer.concat contentBufs).toString()
    xdsMeta = mhd2xds.mhd1Metadata2XdsForMomconnect metadata, cda

    requestTime = new Date()
    correlationId = uuid.v4()

    request.post
      uri: "http://#{config.xdsRepo.host}:#{config.xdsRepo.port}/#{config.xdsRepo.path}"
      method: 'POST'
      headers:
        'content-type': 'multipart/related; type="application/xop+xml"; action="urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b"; start="<metadata@ihe.net>"; start-info="application/soap+xml"'
        'mhd-correlation-id': correlationId
      multipart: [
        'content-type': 'application/xop+xml; charset=UTF-8; type="application/soap+xml"'
        'content-transfer-encoding': 'binary'
        'content-id': '<metadata@ihe.net>'
        body: xdsMeta
      ,
        'content-type': 'text/xml'
        'content-transfer-encoding': 'binary'
        'content-id': "<#{metadata.documentEntry.entryUUID.replace('urn:uuid:', '')}@ihe.net>"
        body: cda.toString('base64')
      ]

    , (err, xdsRes, body) ->
      requestData = requestDataMap[correlationId]
      requestDataMap[correlationId] = null
      urlParts = url.parse requestData.uri
      # Capture orchestration data
      orchestration =
        name:             'MHD to XDS.b mediator request'
        request:
          path:           urlParts.pathname
          headers:        requestData.headers
          querystring:    urlParts.query
          body:           requestData.body
          method:         requestData.method
          timestamp:      requestTime.getTime()
        response:
          status:         xdsRes.statusCode
          headers:        xdsRes.headers
          body:           body
          timestamp:      new Date().getTime()

      if xdsRes.headers['content-type'].indexOf('application/json+openhim') isnt -1
        console.log 'Recieved mediator response...'
        returnObject = JSON.parse body

        # alter orchestration to match the parse response rather
        orchestration.response.status = returnObject.response.status
        orchestration.response.body = returnObject.response.body
        orchestration.response.headers = returnObject.response.headers
        
        # alter existing response object for MHD
        returnObject['x-mediator-urn'] = mediatorConfig.urn
        returnObject.orchestrations.unshift orchestration
        returnObject.response.status = if returnObject.status is 'Successful' then 201 else returnObject.response.status
      else
        console.log 'Recieved non-mediator response...'
        # set response
        status = if /urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success/i.test(body) then 'Successful' else 'Failed'
        response =
          status: if status is 'Successful' then 201 else 400
          headers:
            'content-type': 'application/json'
          body: body
          timestamp: new Date().getTime()

        # construct returnObject to be returned
        returnObject =
          "x-mediator-urn": mediatorConfig.urn
          "status":         status
          "response":       response
          "orchestrations": [orchestration]

      # set content type header so that OpenHIM knows how to handle the response
      res.writeHead returnObject.response.status, 'Content-Type': 'application/json+openhim'
      res.end JSON.stringify returnObject
      console.log 'Responded.'

  # pipe request of to busboy for parsing
  req.pipe busboy
  
# export app for use in unit tests
module.exports = app

if not module.parent
  app.listen 3100, ->
    console.log "mhd2xds mediator is up on port 3100..."