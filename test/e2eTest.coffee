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
        # TODO: test body for correct MIME/XOP correctness
        console.log "The e2e server recieved:\n#{body}"

        console.log '\nmock server writing response...'
        res.writeHead 200, 'content-type': 'application/soap+xml'
        res.end xdsResponse

    server.listen 6644, ->
      console.log 'server listening'
      mhd = fs.readFileSync('test/generated-mhd.txt').toString()
      request('http://localhost:3200')
        .post('/')
        .set('content-type', 'multipart/form-data; boundary=48940923NODERESLTER3890457293')
        .send(mhd)
        .expect(201)
        .end (err, res) ->
          console.log err if err?

          console.log "The mediator returned:\n#{JSON.stringify(JSON.parse(res.text), null, 4)}"
          done()
