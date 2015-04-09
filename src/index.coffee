require('source-map-support').install()

# load express
express = require 'express'
app = express()

# require modules
request = require 'request'
formidable = require 'formidable'
Busboy = require 'busboy'
mhd2xds = require './mhd2xds'

# get config objects
config = require "../config/config"
apiConfig = config.api
mediatorConfig = require "../config/mediator"

# include register script
register = require "./register"
if config.registration.enabled
  console.log config.registration.enabled
  register.registerMediator apiConfig, mediatorConfig

##### Default Endpoint  #####
app.post '/', (req, res) ->

  console.log 'request recieved'

  busboy = new Busboy headers: req.headers

  contentBufs = []
  metadataBufs = []
  metadata = null

  busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
    console.log 'File [' + fieldname + ']: filename: ' + filename + ', encoding: ' + encoding + ', mimetype: ' + mimetype
    if fieldname is 'ihe-mhd-metadata'
      file.on 'data', (chunk) ->
        metadataBufs.push chunk
      file.on 'end', ->
        metadata = JSON.parse(Buffer.concat(metadataBufs))

    if fieldname is 'content'
      file.on 'data', (chunk) ->
        contentBufs.push chunk

  busboy.on 'finish', ->
    console.log 'Finished parsing attachments'

    xdsMeta = mhd2xds.mhd1Metadata2Xds metadata

    request.post
      uri: 'http://localhost:6644/'
      method: 'POST'
      multipart: [
        'content-type': 'application/xop+xml; charset=UTF-8; type="application/soap+xml"'
        'content-transfer-encoding': 'binary'
        'content-id': '<metadata@ihe.net>'
        body: xdsMeta
      ,
        'content-type': 'text/xml'
        'content-transfer-encoding': 'binary'
        'content-id': "<#{metadata.documentEntry.entryUUID.replace('urn:uuid:', '')}@ihe.net>"
        body: (Buffer.concat contentBufs).toString('base64')
      ]
    , (err, xdsRes, body) ->

      # Capture orchestration data
      orchestrationsResults = []
      orchestrationsResults.push
        name:             'XDS.b request'
        request:
          path:           '/'
          headers:        ''
          querystring:    ''
          body:           xdsMeta + '\n===Binary Base64 document data excluded==='
          method:         'POST'
          timestamp:      new Date().getTime()
        response:
          status:         xdsRes.statusCode
          body:           ''
          timestamp:      new Date().getTime()

      # set response
      urn = mediatorConfig.urn
      status = if /urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success/i.test(body) then 'Successful' else 'Failed'
      response =
        status: if status is 'Successful' then 201 else 400
        headers:
          'content-type': 'application/json'
        body: body
        timestamp: new Date().getTime()
       
      # construct returnObject to be returned
      returnObject =
        "x-mediator-urn": urn
        "status":         status
        "response":       response
        "orchestrations": orchestrationsResults

      # set content type header so that OpenHIM knows how to handle the response
      console.log 'responding...'
      res.writeHead response.status, 'Content-Type': 'application/json+openhim'
      res.end JSON.stringify returnObject
      console.log 'responded.'

  # pipe request of to busboy for parsing
  req.pipe busboy
  
# export app for use in grunt-express module
module.exports = app
