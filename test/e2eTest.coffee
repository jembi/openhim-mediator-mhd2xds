fs = require 'fs'
http = require 'http'
request = require 'supertest'
config = require '../config/config'

xdsResponse =
  """
  <?xml version='1.0' encoding='UTF-8'?>
  <soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope"
      xmlns:wsa="http://www.w3.org/2005/08/addressing">
      <soapenv:Header>
          <wsa:Action soapenv:mustUnderstand="true">urn:ihe:iti:2007:RegisterDocumentSet-bResponse</wsa:Action>
          <wsa:RelatesTo>urn:uuid:D9D54C50296A3C11D11220872153270</wsa:RelatesTo>
      </soapenv:Header>
      <soapenv:Body>
          <rs:RegistryResponse xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0"
              status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success"/>
      </soapenv:Body>
  </soapenv:Envelope>
  """

mediatorResponse =
  "x-mediator-urn": "<a unique URN>"
  status: "Successful"
  response:
    status: 200
    headers:
      'content-type': 'application/json'
    body: xdsResponse
    timestamp: new Date().getTime()
  orchestrations: [
    name:             'Upstream orchestration'
    request:
      path:           '/upstream'
      headers:        ''
      querystring:    ''
      body:           'Upstream orchestration'
      method:         'POST'
      timestamp:      new Date().getTime()
    response:
      status:         202
      body:           ''
      timestamp:      new Date().getTime()   
  ]
  properties:
      pro1: "val"
      pro2: "val"

describe 'e2e integration tests', ->

  before (done) ->
    config.registration.enabled = false
    app = require '../lib/index'
    app.listen 3200, ->
      done()

  after ->
    config.registration.enabled = true

  it 'should convert an MHD document to XDS.b and return the XDS.b response in mediator form', (done) ->

    server = http.createServer (req, res) ->
      body = ''
      req.on 'data', (chunk) ->
        body += chunk

      req.on 'end', () ->
        # TODO: test body for correct MIME/XOP correctness
        console.log "The e2e server recieved:\n\n#{body}"

        res.writeHead 200, 'content-type': 'application/soap+xml'
        res.end xdsResponse

    server.listen 6644, ->
      mhd = fs.readFileSync('test/generated-mhd.txt').toString()
      request('http://localhost:3200')
        .post('/')
        .set('content-type', 'multipart/form-data; boundary=48940923NODERESLTER3890457293')
        .send(mhd)
        .expect(201)
        .end (err, res) ->
          throw err if err?

          console.log "The mediator returned:\n\n#{JSON.stringify(JSON.parse(res.text), null, 4)}"
          server.close ->
            done()

  it 'should convert an MHD document to XDS.b and relay a mediator response', (done) ->

    server = http.createServer (req, res) ->
      body = ''
      req.on 'data', (chunk) ->
        body += chunk

      req.on 'end', () ->
        # TODO: test body for correct MIME/XOP correctness
        console.log "The e2e server recieved:\n\n#{body}"

        res.writeHead 200, 'content-type': 'application/json+openhim'
        res.end JSON.stringify mediatorResponse

    server.listen 6644, ->
      mhd = fs.readFileSync('test/generated-mhd.txt').toString()
      request('http://localhost:3200')
        .post('/')
        .set('content-type', 'multipart/form-data; boundary=48940923NODERESLTER3890457293')
        .send(mhd)
        .expect(201)
        .end (err, res) ->
          throw err if err?

          console.log "The mediator returned:\n#{JSON.stringify(JSON.parse(res.text), null, 4)}"
          server.close ->
            done()
