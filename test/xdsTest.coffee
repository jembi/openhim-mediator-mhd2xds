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
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      count = select 'count(//rim:Classification/rim:Slot)', doc

      count.should.be.exactly 2

  describe 'ExternalIdentifier class', ->

    it 'should set name, scheme, regObj and value', ->
      ident = new xds.ExternalIdentifier 'name', 'scheme', 'regObj', 'value'
      xml = js2xml 'ExternalIdentifier', ident
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      name = select 'string(//rim:ExternalIdentifier/rim:Name/rim:LocalizedString/@value)', doc
      scheme = select 'string(//rim:ExternalIdentifier/@identificationScheme)', doc
      regObj = select 'string(//rim:ExternalIdentifier/@registryObject)', doc
      nodeRep = select 'string(//rim:ExternalIdentifier/@value)', doc

      name.should.be.exactly 'name'
      scheme.should.be.exactly 'scheme'
      regObj.should.be.exactly 'regObj'
      nodeRep.should.be.exactly 'value'

  describe 'DocumentEntry class', ->

    it 'should set the require attributes', ->
      docEntry = new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      entryUUID = select 'string(//rim:ExtrinsicObject/@id)', doc
      mimeType = select 'string(//rim:ExtrinsicObject/@mimeType)', doc
      availabilityStatus = select 'string(//rim:ExtrinsicObject/@status)', doc
      objectType = select 'string(//rim:ExtrinsicObject/@objectType)', doc

      entryUUID.should.be.exactly 'entryUUID'
      mimeType.should.be.exactly 'mimeType'
      availabilityStatus.should.be.exactly 'availabilityStatus'
      objectType.should.be.exactly 'urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1'

    it 'should set the required slots', ->
      docEntry = new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      hash = select 'boolean(//rim:ExtrinsicObject/rim:Slot[@name="hash"])', doc
      size = select 'boolean(//rim:ExtrinsicObject/rim:Slot[@name="size"])', doc
      languageCode = select 'boolean(//rim:ExtrinsicObject/rim:Slot[@name="languageCode"])', doc
      repositoryUniqueId = select 'boolean(//rim:ExtrinsicObject/rim:Slot[@name="repositoryUniqueId"])', doc
      sourcePatientId = select 'boolean(//rim:ExtrinsicObject/rim:Slot[@name="sourcePatientId"])', doc
      creationTime = select 'boolean(//rim:ExtrinsicObject/rim:Slot[@name="creationTime"])', doc

      hash.should.be.exactly true
      size.should.be.exactly true
      languageCode.should.be.exactly true
      repositoryUniqueId.should.be.exactly true
      sourcePatientId.should.be.exactly true
      creationTime.should.be.exactly true

    checkGeneralClassification = (doc, clazzScheme, name, code, scheme) ->
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      exists = select "boolean(//rim:ExtrinsicObject/rim:Classification[@classificationScheme='#{clazzScheme}'])", doc
      exists.should.be.exactly true

      nameVal = select "string(//rim:ExtrinsicObject/rim:Classification[@classificationScheme='#{clazzScheme}']/rim:Name/rim:LocalizedString/@value)", doc
      codeVal = select "string(//rim:ExtrinsicObject/rim:Classification[@classificationScheme='#{clazzScheme}']/@nodeRepresentation)", doc
      schemeVal = select "string(//rim:ExtrinsicObject/rim:Classification[@classificationScheme='#{clazzScheme}']/rim:Slot/rim:ValueList/rim:Value)", doc

      nameVal.should.be.exactly name
      codeVal.should.be.exactly code
      schemeVal.should.be.exactly scheme

    it 'should set classCode classification', ->
      docEntry = new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a', 'clazzName', 'clazzCode', 'clazzScheme'

    it 'should set confidentialityCode classification', ->
      docEntry = new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f', 'confidentialityName', 'confidentialityCode', 'confidentialityScheme'
      
    it 'should set eventCode classification', ->
      docEntry = new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:2c6b8cb7-8b2a-4051-b291-b1ae6a575ef4', 'eventName', 'eventCode', 'eventScheme'

    it 'should set formatCode classification', ->
      docEntry = new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d', 'formatName', 'formatCode', 'formatScheme'

    it 'should set healthcareFacilityTypeCode classification', ->
      docEntry = new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1', 'healthcareFacilityTypeName', 'healthcareFacilityTypeCode', 'healthcareFacilityTypeScheme'

    it 'should set practiceSettingCode classification', ->
      docEntry = new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead', 'practiceSettingName', 'practiceSettingCode', 'practiceSettingScheme'

    it 'should set typeCode classification', ->
      docEntry = new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:f0306f51-975f-434e-a61c-c59651d33983', 'typeName', 'typeCode', 'typeScheme'

    checkGeneralExternalIdentifier = (doc, identScheme, name, regObj, value) ->
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      exists = select "boolean(//rim:ExtrinsicObject/rim:ExternalIdentifier[@identificationScheme='#{identScheme}'])", doc
      exists.should.be.exactly true

      regObjVal = select "string(//rim:ExtrinsicObject/rim:ExternalIdentifier[@identificationScheme='#{identScheme}']/@registryObject)", doc
      valueVal = select "string(//rim:ExtrinsicObject/rim:ExternalIdentifier[@identificationScheme='#{identScheme}']/@value)", doc
      nameVal = select "string(//rim:ExtrinsicObject/rim:ExternalIdentifier[@identificationScheme='#{identScheme}']/rim:Name/rim:LocalizedString/@value)", doc

      regObjVal.should.be.exactly regObj
      valueVal.should.be.exactly value
      nameVal.should.be.exactly name

    it 'should set the required external identifiers', ->
      docEntry = new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralExternalIdentifier doc, 'urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427', 'XDSDocumentEntry.patientId', 'entryUUID', 'patientId'

    it 'should set the required external identifiers', ->
      docEntry = new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralExternalIdentifier doc, 'urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab', 'XDSDocumentEntry.uniqueId', 'entryUUID', 'uniqueId'