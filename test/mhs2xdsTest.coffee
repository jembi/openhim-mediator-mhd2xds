mhd2xds = require '../lib/mhd2xds'

describe 'mhs2xds unit tests', ->

  it 'should convert mhd v1 metadata to xds.b metadata without error', ->
    xds = mhd2xds.mhd1Metadata2Xds
      "documentEntry":
        "patientId": "7612241234567^^^ZAF^NI"
        "uniqueId": "2.15.278071478427527610493133229150878247572"
        "entryUUID": "urn:uuid:d1329e63-0408-4f45-b5ba-35f9afa72a94"
        "classCode":
          "code": "51855-5"
          "codingScheme": "2.16.840.1.113883.6.1"
          "codeName": "Patient Note"
        "typeCode":
          "code": "51855-5"
          "codingScheme": "2.16.840.1.113883.6.1"
          "codeName": "Patient Note"
        "formatCode":
          "code": "npr-pn-cda"
          "codingScheme": "4308822c-d4de-49db-9bb8-275394ee971d"
          "codeName": "NPR Patient Note CDA"
        "mimeType": "text/xml"
        "hash": "3664a16caf255c9d481b470a7a1a47c92f92ff5b"
        "size": "4846"

    console.log 'XDS metadata that was generated:\n\n' + xds