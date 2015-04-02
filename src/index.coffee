require('source-map-support').install()

# load modules
express = require 'express'
app = express()

# get config objects
config = require "../config/config"
apiConfig = config.api
mediatorConfig = require "../config/mediator"

# include register script
register = require "./register"
register.registerMediator apiConfig, mediatorConfig


#########################
##### Server Setup  #####
#########################

##### Default Endpoint  #####
app.get '/', (req, res) ->

  #########################################
  ##### Create Initial Orchestration  #####
  #########################################
   
  response = 'Primary Route Reached'

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
      body:           response
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
  
# export app for use in grunt-express module
module.exports = app

#########################
##### Server Setup  #####
#########################
