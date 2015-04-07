js2xml = require 'js2xmlparser'

header =
  '@':
    'xmlns:a': 'http://www.w3.org/2005/08/addressing'
  'a:Action':
    '@':
      'soap:mustUnderstand': 'true'
    '#': 'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b'
  'a:To':
    '@':
      'soap:mustUnderstand': 'true'
    '#': 'https://localhost:5000/xdsrepository'
  'a:MessageID': null
  'a:ReplyTo':
    '@':
      'soap:mustUnderstand': 'true'
    'a:Address': 'http://www.w3.org/2005/08/addressing/anonymous'

pnr =
  '@':
    'xmlns': 'urn:ihe:iti:xds-b:2007'

js2xmlPnr =
  '@':
    'xmlns:soap': 'http://www.w3.org/2003/05/soap-envelope'
  'soap:Header': header
  'soap:Body':
    'ProvideAndRegisterDocumentSetRequest': pnr

exports.mhd1Metadata2Xds = (metadata) ->
  return js2xml 'soap:Envelope', js2xmlPnr

exports.mhd2Metadata2Xds = (metadata) ->
  throw new Error 'Not implemented'