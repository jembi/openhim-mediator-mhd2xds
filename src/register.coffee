##################################
##### Mediator Registration  #####
##################################

needle = require 'needle'
crypto = require 'crypto'

exports.registerMediator = (apiConfig, mediatorConfig) ->
  # used to bypass self signed certificates
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

  # define login credentails for authorization
  username = apiConfig.username
  password = apiConfig.password
  apiURL = apiConfig.apiURL

  # authenticate the username
  needle.get "#{apiURL}/authenticate/#{username}", (err, resp, body) ->
    
    console.log 'Attempting to create/update mediator'

    # print error if exist
    if err?
      console.log err
      return
    
    # if user isnt found - console log response body
    if resp.statusCode isnt 200
      console.error "Couldn't find user in OpenHIM, here is the response we recieved: #{resp.body}"
      return
    
    # create passhash
    shasum = crypto.createHash 'sha512'
    shasum.update (body.salt + password)
    passhash = shasum.digest 'hex'

    # create token
    shasum = crypto.createHash 'sha512'
    shasum.update (passhash + body.salt + body.ts)
    token = shasum.digest 'hex'

    # define request headers with auth credentails
    options =
      json: true
      headers:
        'auth-username':  username,
        'auth-ts':        body.ts,
        'auth-salt':      body.salt,
        'auth-token':     token

    # POST mediator to API for creation/update
    needle.post "#{apiURL}/mediators", mediatorConfig, options, (err, resp) ->
      
      # print error if exist
      if err?
        console.error err
        return

      # check the response status from the API server
      if resp.statusCode is 201
        # successfully created/updated
        console.log 'Mediator has been successfully created/updated.'
      else
        console.log "An error occured while trying to create/update the mediator: #{resp.body}"

##################################
##### Mediator Registration  #####
##################################
