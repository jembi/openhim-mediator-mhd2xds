js2xml = require 'js2xmlparser'

createName = (name, charset, lang) ->
  name =
    'LocalizedString':
      '@':
        'charset': charset
        'value': name
        'xml:lang': lang

  return name

createSlot = (name, vals...) ->
  slot =
    '@':
      'name': name
    'ValueList': []

  for val in vals
    slot.ValueList.push 'Value': val

  return slot

createClassification = (name, scheme, obj, id, nodeRep, classNode, slots...) ->
  classification =
    '@':
      'classificationScheme': scheme
      'classifiedObject': obj
      'id': id
      'nodeRepresentation': nodeRep
      'classificationNode': classNode
    'Slot': []
    'Name': createName(name, 'UTF-8', 'us-en')

  for slot in slots
    classification.Slot.push slot

  return classification

createExternalIdentifier = (name, scheme, regObj, value) ->
  identifer =
    '@':
      'id': ''
      'identificationScheme': scheme
      'registryObject': regObj
      'value': value
    'Name': createName(name, 'UTF-8', 'us-en')

createExtrinsicObject = ->
  obj =
    '@':
      'id': null
      'mimeType': null
      'objectType': null
    'Slot': [
      createSlot 'creationTime', null
    ,
      createSlot 'languageCode', 'en-us'
    ,
      createSlot 'serviceStartTime', null
    ,
      createSlot 'serviceStopTime', null
    ,
      createSlot 'sourcePatientId', null
    ,
      createSlot 'sourcePatientInfo', null
    ]
    'Classification': [
      # DocumentEntry.author
      createClassification(
        null,
        'urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d',
        null,
        'urn:uuid:700f61d9-2a3f-45ef-aae7-e0134fab2d54',
        null,
        null,
        createSlot('authorPerson', null),
        createSlot('authorInstitution', null))
    ,
      # DocumentEntry.classCode
      createClassification(
        'Workflow',
        'urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a',
        null,
        'urn:uuid:db1c5333-ed3c-41cc-b8ed-420ea2e15b6c',
        null,
        null,
        createSlot('codingScheme', null))
    ,
      # DocumentEntry.confidentialityCode
      createClassification(
        'Normal',
        'urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f',
        null,
        'urn:uuid:1cd1c537-f495-4dfd-b1dc-2a82d3c61d36',
        null,
        null,
        createSlot('codingScheme', null))
    ,
      # DocumentEntry.formatCode
      createClassification(
        null,
        'urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d',
        null,
        'urn:uuid:c03fa039-d7bc-406f-8007-b74038d69cb5',
        null,
        null,
        createSlot('codingScheme', null))
    ,
      # DocumentEntry.healthcareFacilityTypeCode
      createClassification(
        null,
        'urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1',
        null,
        'urn:uuid:c03fa039-d7bc-406f-8007-b74038d69cb5',
        null,
        null,
        createSlot('codingScheme', null))
    ,
      # DocumentEntry.practiceSettingCode
      createClassification(
        null,
        'urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead',
        null,
        'urn:uuid:2c3b041a-2696-4333-8a68-e09e6ce70090',
        null,
        null,
        createSlot('codingScheme', null))
    ,
      # DocumentEntry.typeCode
      createClassification(
        null,
        'urn:uuid:f0306f51-975f-434e-a61c-c59651d33983',
        null,
        'urn:uuid:e51e9cce-978c-40bf-a864-0f1da10425aa',
        null,
        null,
        createSlot('codingScheme', null))
    ]
    'ExternalIdentifier': [
      createExternalIdentifier(
        'XDSDocumentEntry.patientId',
        'urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427',
        null,
        null)
    ,
      createExternalIdentifier(
        'XDSDocumentEntry.uniqueId',
        'urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab',
        null,
        null)
    ]

  return obj

createRegistryPackage = ->
  pkg =
    '@':
      'id': 'urn:uuid:c0149d06-7f32-4453-b28e-c4d5244c35ee'
    'Slot': [
      createSlot 'submissionTime', null
    ]
    'Classification': [
      # SubmissionSet.contentTypeCode
      createClassification(
        null,
        'urn:uuid:aa543740-bdda-424e-8c96-df4873be8500',
        null,
        'urn:uuid:63504f8a-9229-4307-bef5-14e8ee3e134c',
        null,
        null,
        createSlot('codingScheme', null))
    ]
    'ExternalIdentifier': [
      createExternalIdentifier(
        'XDSSubmissionSet.patientId',
        'urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446',
        null,
        null)
    ,
      createExternalIdentifier(
        'XDSSubmissionSet.uniqueId',
        'urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8',
        null,
        null)
    ,
      createExternalIdentifier(
        'XDSSubmissionSet.sourceId',
        'urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832',
        null,
        null)
    ]

  return pkg

createAssociation = (type, srcObj, targetObj, slotName, slotValue) ->
  '@':
    'associationType': type
    'id': 'urn:uuid:c9abae3c-688f-4505-a136-bd99ca5019fb'
    'sourceObject': srcObj
    'targetObject': targetObj
  'Slot': createSlot slotName, slotValue

createDocument = (id, href) ->
  doc =
    '@':
      'id': id
    'xop:Include':
      '@':
        'xmlns:xop': 'http://www.w3.org/2004/08/xop/include'
        'href': href

  return doc

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
    'xmlns': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'
    'xmlns:xds': 'urn:ihe:iti:xds-b:2007'
    'xmlns:lcm': 'urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0'
    'xmlns:query': 'urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0'
    'xmlns:rs': 'urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0'
  'lcm:SubmitObjectsRequest':
    'RegistryObjectList':
      'ExtrinsicObject': createExtrinsicObject()
      'RegistryPackage': createRegistryPackage()
      # Classisify registry package as a submission set
      'Classification': createClassification(
        null,
        null,
        null,
        'urn:uuid:f1c82f24-d91d-4945-8a63-81d06f3ee995',
        null,
        'urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd',
        createSlot('codingScheme', null))
      'Association': [
        createAssociation 'urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember', null, null, 'SubmissionSetStatus', 'Original'
      ]
      'Document': [
        createDocument null, 'cid:document@ihe.net'
      ]

js2xmlPnr =
  '@':
    'xmlns:soap': 'http://www.w3.org/2003/05/soap-envelope'
  'soap:Header': header
  'soap:Body':
    'xds:ProvideAndRegisterDocumentSetRequest': pnr

exports.mhd1Metadata2Xds = (metadata) ->
  return js2xml 'soap:Envelope', js2xmlPnr

exports.mhd2Metadata2Xds = (metadata) ->
  throw new Error 'Not implemented'
