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

  describe 'Slot class', ->

    it 'should contain name', ->
      slot = new xds.Slot('name', 'val')
      xml = js2xml 'Slot', slot
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      name = select 'string(//rim:Slot/@name)', doc

      name.should.be.exactly 'name'

    it 'should contain single value', ->
      slot = new xds.Slot('name', 'val1')
      xml = js2xml 'Slot', slot
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      count = select 'count(//rim:Slot/rim:ValueList/rim:Value)', doc
      val = select 'string(//rim:Slot/rim:ValueList/rim:Value)', doc

      count.should.be.exactly 1
      val.should.be.exactly 'val1'

    it 'should conmtain multiple values', ->
      slot = new xds.Slot('name', 'val1', 'val2', 'val3')
      xml = js2xml 'Slot', slot
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      count = select 'count(//rim:Slot/rim:ValueList/rim:Value)', doc
      val1 = select 'string(//rim:Slot/rim:ValueList/rim:Value[1])', doc
      val2 = select 'string(//rim:Slot/rim:ValueList/rim:Value[2])', doc
      val3 = select 'string(//rim:Slot/rim:ValueList/rim:Value[3])', doc

      count.should.be.exactly 3
      val1.should.be.exactly 'val1'
      val2.should.be.exactly 'val2'
      val3.should.be.exactly 'val3'