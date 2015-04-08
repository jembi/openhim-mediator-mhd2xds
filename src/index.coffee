#require('source-map-support').install()

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


#########################
##### Server Setup  #####
#########################

##### Default Endpoint  #####
app.post '/', (req, res) ->

  console.log 'request recieved'

  #body = ''
  #req.on 'data', (chunk) ->
  #  body += chunk

  #req.on 'end', ->

  # do mhdv1 to xds.b conversion ...
  #form = new formidable.IncomingForm()

  #form.parse req, (err, fields, files) ->
  #  console.error err if err?
    
  #  if not files['ihe-mhd-metadata']? and not files['content']?
  #    throw new Error 'No ihe-mhd-metadata or content attachments found.'

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
    console.log metadata
    #console.log content
    request.post
      uri: 'http://localhost:6644/'
      method: 'POST'
      multipart: [
        'content-type': 'application/xop+xml; charset=UTF-8; type="application/soap+xml"'
        'content-transfer-encoding': 'binary'
        'content-id': '<metadata@ihe.net>'
        body: mhd2xds.mhd1Metadata2Xds metadata
      ,
        'content-type': 'text/xml'
        'content-transfer-encoding': 'binary'
        'content-id': '<document@ihe.net>'
        body: (Buffer.concat contentBufs).toString('base64')
      ]
    , (err, res, body) ->

      # convert response back to mhdv1

      #########################################
      ##### Create Initial Orchestration  #####
      #########################################
       
      # context object to store json objects
      ctxObject = {}
      ctxObject['primary'] = response
       
      # Capture 'primary' orchestration data
      orchestrationsResults = []
      orchestrationsResults.push
        name:             'Primary Route'
        request:
          path:           req.path
          headers:        req.headers
          querystring:    req.originalUrl.replace req.path, ""
          body:           req.body
          method:         req.method
          timestamp:      new Date().getTime()
        response:
          status:         200
          body:           body
          timestamp:      new Date().getTime()

      ######################################
      ##### Construct Response Object  #####
      ######################################
       
      urn = mediatorConfig.urn
      status = 'Successful'
      response =
        status: 200
        headers:
          'content-type': 'application/json'
        body: response
        timestamp: new Date().getTime()
       
      # construct property data to be returned
      properties = {}
      properties['property'] = 'Primary Route'
       
      # construct returnObject to be returned
      returnObject =
        "x-mediator-urn": urn
        "status":         status
        "response":       response
        "orchestrations": orchestrationsResults
        "properties":     properties

      # set content type header so that OpenHIM knows how to handle the response
      res.set 'Content-Type', 'application/json+openhim'
      res.send returnObject

  # pipe request of to busboy for parsing
  req.pipe busboy
  
# export app for use in grunt-express module
module.exports = app

#########################
##### Server Setup  #####
#########################
