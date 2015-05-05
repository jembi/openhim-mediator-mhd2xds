xds = require '../lib/xds'
js2xml = require 'js2xmlparser'
xpath = require 'xpath'
dom = require('xmldom').DOMParser
should = require 'should'

describe 'XDS class Tests', ->

  describe 'Name class', ->

    it 'should contain name, charset and lang', ->
      name = new xds.Name 'name', 'UTF-8', 'en-GB'
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
      slot = new xds.Slot 'name', 'val'
      xml = js2xml 'Slot', slot
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      name = select 'string(//rim:Slot/@name)', doc

      name.should.be.exactly 'name'

    it 'should contain single value', ->
      slot = new xds.Slot 'name', 'val1'
      xml = js2xml 'Slot', slot
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      count = select 'count(//rim:Slot/rim:ValueList/rim:Value)', doc
      val = select 'string(//rim:Slot/rim:ValueList/rim:Value)', doc

      count.should.be.exactly 1
      val.should.be.exactly 'val1'

    it 'should contain multiple values', ->
      slot = new xds.Slot 'name', 'val1', 'val2', 'val3'
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

  describe 'Classification class', ->

    it 'should set name, scheme, obj, nodeRep and classNode', ->
      clazz = new xds.Classification 'name', 'scheme', 'obj', 'nodeRep', 'classNode'
      xml = js2xml 'Classification', clazz
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      name = select 'string(//rim:Classification/rim:Name/rim:LocalizedString/@value)', doc
      scheme = select 'string(//rim:Classification/@classificationScheme)', doc
      obj = select 'string(//rim:Classification/@classifiedObject)', doc
      nodeRep = select 'string(//rim:Classification/@nodeRepresentation)', doc
      classNode = select 'string(//rim:Classification/@classificationNode)', doc

      name.should.be.exactly 'name'
      scheme.should.be.exactly 'scheme'
      obj.should.be.exactly 'obj'
      nodeRep.should.be.exactly 'nodeRep'
      classNode.should.be.exactly 'classNode'

    it 'should set multiple slots', ->
      slot1 = new xds.Slot 'name1', 'val1', 'val2', 'val3'
      slot2 = new xds.Slot 'name2', 'val1', 'val2'
      clazz = new xds.Classification 'name', 'scheme', 'obj', 'nodeRep', 'classNode', slot1, slot2
      xml = js2xml 'Classification', clazz
      console.log xml
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      count = select 'count(//rim:Classification/rim:Slot)', doc

      count.should.be.exactly 2