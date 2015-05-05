xds = require '../lib/xds'
js2xml = require 'js2xmlparser'
xpath = require 'xpath'
dom = require('xmldom').DOMParser
should = require 'should'

describe 'XDS class Tests', ->

  describe 'Name class', ->

    it 'should contain name, charset and lang', ->
      name = new xds.Name('name', 'UTF-8', 'en-GB')
      xml = js2xml 'Name', name
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      charset = select 'string(//rim:Name/rim:LocalizedString/@charset)', doc
      nameVal = select 'string(//rim:Name/rim:LocalizedString/@value)', doc
      lang = select 'string(//rim:Name/rim:LocalizedString/@lang)', doc

      charset.should.be.exactly 'UTF-8'
      nameVal.should.be.exactly 'name'
      lang.should.be.exactly 'en-GB'