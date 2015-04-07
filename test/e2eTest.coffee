fs = require 'fs'
http = require 'http'
request = require 'supertest'
config = require '../config/config'

describe 'e2e integration tests', ->

  before (done) ->
    console.log 'set enabled to false'
    config.registration.enabled = false
    app = require '../lib/index'
    app.listen 3200, ->
      done()

  after ->
    console.log 'set enabled to true'
    config.registration.enabled = true

  it 'should convert an MHD document to XDS.b', (done) ->

    server = http.createServer (req, res) ->
      body = ''
      req.on 'data', (chunk) ->
        body += chunk

      req.on 'end', () ->
        # test body for correct XDS.b-ness
        console.log body
        done()

    server.listen 6644, ->
      console.log 'server listening'
      mhd = fs.readFileSync('test/generated-mhd.txt').toString()
      request('http://localhost:3200')
        .post('/')
        .set('content-type', 'multipart/form-data; boundary=48940923NODERESLTER3890457293')
        .send(mhd)
        .expect(200)
        .end (err, res) ->
          console.log err if err?
