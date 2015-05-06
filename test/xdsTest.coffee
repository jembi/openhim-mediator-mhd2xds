xds = require '../lib/xds'
js2xml = require 'js2xmlparser'
xpath = require 'xpath'
dom = require('xmldom').DOMParser
should = require 'should'

describe 'XDS class Tests', ->

  constructTestDocEntry = ->
    return new xds.DocumentEntry 'entryUUID', 'mimeType', 'availabilityStatus', 'hash', 'size', 'languageCode', 'repositoryUniqueId', 'sourcePatientId', 'patientId', 'uniqueId', 'creationTime', { code: 'clazzCode', name: 'clazzName', scheme: 'clazzScheme' }, { code: 'confidentialityCode', name: 'confidentialityName', scheme: 'confidentialityScheme' }, { code: 'eventCode', name: 'eventName', scheme: 'eventScheme' }, { code: 'formatCode', name: 'formatName', scheme: 'formatScheme' }, { code: 'healthcareFacilityTypeCode', name: 'healthcareFacilityTypeName', scheme: 'healthcareFacilityTypeScheme' }, { code: 'practiceSettingCode', name: 'practiceSettingName', scheme: 'practiceSettingScheme' }, { code: 'typeCode', name: 'typeName', scheme: 'typeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]

  constructTestSubSet = ->
    return new xds.SubmissionSet 'entryUUID', 'availabilityStatus', 'submissionTime', 'patientId', 'sourceId', 'uniqueId', { code: 'contentTypeCode', name: 'contentTypeName', scheme: 'contentTypeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]

  constructTestPNR = ->
    return new xds.ProvideAndRegisterDocumentSetRequest(
      [
        constructTestDocEntry()
      ,
        constructTestDocEntry()
      ]
      ,
      constructTestSubSet())

  checkGeneralClassification = (doc, clazzScheme, name, code, scheme) ->
    select = xpath.useNamespaces
      'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

    exists = select "boolean(//*/rim:Classification[@classificationScheme='#{clazzScheme}'])", doc
    exists.should.be.exactly true

    nameVal = select "string(//*/rim:Classification[@classificationScheme='#{clazzScheme}']/rim:Name/rim:LocalizedString/@value)", doc
    codeVal = select "string(//*/rim:Classification[@classificationScheme='#{clazzScheme}']/@nodeRepresentation)", doc
    schemeVal = select "string(//*/rim:Classification[@classificationScheme='#{clazzScheme}']/rim:Slot/rim:ValueList/rim:Value)", doc

    nameVal.should.be.exactly name
    codeVal.should.be.exactly code
    schemeVal.should.be.exactly scheme

  checkGeneralExternalIdentifier = (doc, identScheme, name, regObj, value) ->
    select = xpath.useNamespaces
      'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

    exists = select "boolean(//*/rim:ExternalIdentifier[@identificationScheme='#{identScheme}'])", doc
    exists.should.be.exactly true

    regObjVal = select "string(//*/rim:ExternalIdentifier[@identificationScheme='#{identScheme}']/@registryObject)", doc
    valueVal = select "string(//*/rim:ExternalIdentifier[@identificationScheme='#{identScheme}']/@value)", doc
    nameVal = select "string(//*/rim:ExternalIdentifier[@identificationScheme='#{identScheme}']/rim:Name/rim:LocalizedString/@value)", doc

    regObjVal.should.be.exactly regObj
    valueVal.should.be.exactly value
    nameVal.should.be.exactly name

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
      docEntry = constructTestDocEntry()
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
      docEntry = constructTestDocEntry()
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

    it 'should set classCode classification', ->
      docEntry = constructTestDocEntry()
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a', 'clazzName', 'clazzCode', 'clazzScheme'

    it 'should set confidentialityCode classification', ->
      docEntry = constructTestDocEntry()
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f', 'confidentialityName', 'confidentialityCode', 'confidentialityScheme'
      
    it 'should set eventCode classification', ->
      docEntry = constructTestDocEntry()
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:2c6b8cb7-8b2a-4051-b291-b1ae6a575ef4', 'eventName', 'eventCode', 'eventScheme'

    it 'should set formatCode classification', ->
      docEntry = constructTestDocEntry()
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d', 'formatName', 'formatCode', 'formatScheme'

    it 'should set healthcareFacilityTypeCode classification', ->
      docEntry = constructTestDocEntry()
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1', 'healthcareFacilityTypeName', 'healthcareFacilityTypeCode', 'healthcareFacilityTypeScheme'

    it 'should set practiceSettingCode classification', ->
      docEntry = constructTestDocEntry()
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead', 'practiceSettingName', 'practiceSettingCode', 'practiceSettingScheme'

    it 'should set typeCode classification', ->
      docEntry = constructTestDocEntry()
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:f0306f51-975f-434e-a61c-c59651d33983', 'typeName', 'typeCode', 'typeScheme'

    it 'should set the patientId external identifier', ->
      docEntry = constructTestDocEntry()
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralExternalIdentifier doc, 'urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427', 'XDSDocumentEntry.patientId', 'entryUUID', 'patientId'

    it 'should set the uniqueId external identifier', ->
      docEntry = constructTestDocEntry()
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml

      checkGeneralExternalIdentifier doc, 'urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab', 'XDSDocumentEntry.uniqueId', 'entryUUID', 'uniqueId'

    it 'should set author classification', ->
      docEntry = constructTestDocEntry()
      xml = js2xml 'ExtrinsicObject', docEntry
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      authorVal = select 'string(//*/rim:Classification[@classificationScheme="urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d"]/rim:Slot[@name="authorSlot"]/rim:ValueList/rim:Value)', doc
      authorVal.should.be.exactly 'authorVal'

  describe 'SubmissionSet class', ->

    it 'should set the required attributes', ->
      subSet = new xds.SubmissionSet 'entryUUID', 'availabilityStatus', 'submissionTime', 'patientId', 'sourceId', 'uniqueId', { code: 'contentTypeCode', name: 'contentTypeName', scheme: 'contentTypeScheme' }, [ new xds.Slot 'authorSlot', 'authorVal' ]
      xml = js2xml 'RegistryPackage', subSet
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      entryUUID = select 'string(//rim:RegistryPackage/@id)', doc
      avalabilityStatus = select 'string(//rim:RegistryPackage/@status)', doc

      entryUUID.should.be.exactly 'entryUUID'
      avalabilityStatus.should.be.exactly 'availabilityStatus'

    it 'should set contentTypeCode classification', ->
      subSet = constructTestSubSet()
      xml = js2xml 'RegistryPackage', subSet
      doc = new dom().parseFromString xml

      checkGeneralClassification doc, 'urn:uuid:aa543740-bdda-424e-8c96-df4873be8500', 'contentTypeName', 'contentTypeCode', 'contentTypeScheme'

    it 'should set the patientId external identifier', ->
      subSet = constructTestSubSet()
      xml = js2xml 'RegistryPackage', subSet
      doc = new dom().parseFromString xml

      checkGeneralExternalIdentifier doc, 'urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446', 'XDSSubmissionSet.patientId', 'entryUUID', 'patientId'

    it 'should set the sourceId external identifier', ->
      subSet = constructTestSubSet()
      xml = js2xml 'RegistryPackage', subSet
      doc = new dom().parseFromString xml

      checkGeneralExternalIdentifier doc, 'urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832', 'XDSSubmissionSet.sourceId', 'entryUUID', 'sourceId'

    it 'should set the uniqueId external identifier', ->
      subSet = constructTestSubSet()
      xml = js2xml 'RegistryPackage', subSet
      doc = new dom().parseFromString xml

      checkGeneralExternalIdentifier doc, 'urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8', 'XDSSubmissionSet.uniqueId', 'entryUUID', 'uniqueId'

    it 'should set author classification', ->
      subSet = constructTestSubSet()
      xml = js2xml 'RegistryPackage', subSet
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'

      authorVal = select 'string(//*/rim:Classification[@classificationScheme="urn:uuid:a7058bb9-b4e4-4307-ba5b-e3f0ab85e12d"]/rim:Slot[@name="authorSlot"]/rim:ValueList/rim:Value)', doc
      authorVal.should.be.exactly 'authorVal'

  describe 'ProvideAndRegisterDocumentSetRequest class', ->

    it 'should set the submissions set', ->
      pnr = new xds.ProvideAndRegisterDocumentSetRequest(
        [
          constructTestDocEntry()
          ,
          constructTestDocEntry()
        ]
        ,
        constructTestSubSet())
      xml = js2xml 'ProvideAndRegisterDocumentSetRequest', pnr
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'
        'lcm': 'urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0'
        'xds': 'urn:ihe:iti:xds-b:2007'

      exists = select 'boolean(//xds:ProvideAndRegisterDocumentSetRequest/lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:RegistryPackage)', doc
      exists.should.be.exactly true

    it 'should set the document entries', ->
      pnr = constructTestPNR()
      xml = js2xml 'ProvideAndRegisterDocumentSetRequest', pnr
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'rim': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'
        'lcm': 'urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0'
        'xds': 'urn:ihe:iti:xds-b:2007'

      eoExists = select 'count(//xds:ProvideAndRegisterDocumentSetRequest/lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:ExtrinsicObject)', doc
      associationExists = select 'count(//xds:ProvideAndRegisterDocumentSetRequest/lcm:SubmitObjectsRequest/rim:RegistryObjectList/rim:Association)', doc
      docExists = select 'count(//xds:ProvideAndRegisterDocumentSetRequest/xds:Document)', doc

      eoExists.should.be.exactly 2
      associationExists.should.be.exactly 2
      docExists.should.be.exactly 2

  describe 'SoapHeader class', ->

    it 'should set required soap header attributes', ->
      header = new xds.SoapHeader 'MessageID', 'to'
      xml = js2xml 'Header', header
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'soap': 'http://www.w3.org/2003/05/soap-envelope'
        'a': 'http://www.w3.org/2005/08/addressing'

      action = select 'string(//soap:Header/a:Action[@mustUnderstand="true"])', doc
      to = select 'string(//soap:Header/a:To[@mustUnderstand="true"])', doc
      messageID = select 'string(//soap:Header/a:MessageID)', doc
      replyTo = select 'string(//soap:Header/a:ReplyTo[@mustUnderstand="true"]/a:Address)', doc

      action.should.be.exactly 'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b'
      to.should.be.exactly 'to'
      messageID.should.be.exactly 'MessageID'
      replyTo.should.be.exactly 'http://www.w3.org/2005/08/addressing/anonymous'

  describe 'SaopEnvelope class', ->

    it 'should set the require soap envelope attributes', ->
      env = new xds.SoapEnvelope constructTestPNR()
      xml = js2xml 'Envelope', env
      doc = new dom().parseFromString xml
      select = xpath.useNamespaces
        'soap': 'http://www.w3.org/2003/05/soap-envelope'
        'xds': 'urn:ihe:iti:xds-b:2007'

      headerExists = select 'boolean(//soap:Envelope/soap:Header)', doc
      pnrExists = select 'boolean(//soap:Envelope/soap:Body/xds:ProvideAndRegisterDocumentSetRequest)', doc

      headerExists.should.be.exactly true
      pnrExists.should.be.exactly true
