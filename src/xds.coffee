uuid = require 'node-uuid'

exports.Name = class Name
  constructor: (name, charset, lang) ->
    @LocalizedString =
      '@':
        'charset': charset
        'value': name
        'xml:lang': lang

exports.Slot = class Slot
  constructor: (name, vals...) ->
    @['@'] =
      'name': name
    @ValueList = []

    for val in vals
      @ValueList.push 'Value': val

  addValue: (val) ->
    @ValueList.push 'Value': val

exports.Classification = class Classification
  constructor: (name, scheme, obj, nodeRep, classNode, slots...) ->
    @['@'] =
      'id': 'urn:uuid:' + uuid.v4()
      'classificationScheme': scheme
      'classifiedObject': obj
      'nodeRepresentation': nodeRep
      'classificationNode': classNode
      'objectType': 'urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification'
    @Slot = []
    @Name = new Name(name, 'UTF-8', 'us-en')

    for slot in slots
      @Slot.push slot

  addSlot: (slot) ->
    @Slot.push slot

exports.ExternalIdentifier = class ExternalIdentifier
  constructor: (name, scheme, regObj, value) ->
    @['@'] =
      'id': 'urn:uuid:' + uuid.v4()
      'identificationScheme': scheme
      'registryObject': regObj
      'value': value
      'objectType': 'urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier'
    @Name = new Name(name, 'UTF-8', 'us-en')

###
# DocumentEntry.
#  entryUUID - in form 'urn:uuid:a6e06ca8-0c75-4064-9e5c-88b9045a96f6'
#  mimeType - eg. application/pdf
#  availabilityStatus - urn:oasis:names:tc:ebxml-regrep:StatusType:Approved or urn:oasis:names:tc:ebxml-regrep:StatusType:Deprecated
#  hash - SHA1 hash of the document
#  size - Size of the document in bytes
#  languageCode - language of the document eg. en-ZA
#  repositoryUniqueId - unique id for the repository where this document can be found
#  sourcePatientId - the patient id in the source system that generated the document
#  patientId - the patient id in the XDS affinity domain in CX form eg. 6578946^^^&amp;1.3.6.1.4.1.21367.2005.3.7&amp;ISO
#  uniqueId - globally unique identifier for the document in OID form eg. '1.2.3.51.21.55555'
#  creationTime - the time the author created the document in DTM format (YYYY[MM[DD[hh[mm[ss]]]]] in UTC time) eg. 20050102030405
#  clazz - in form { code: x, name: y, scheme: z }, the classCode to broadly classify the document along with its display name and coding scheme
#  confidentiality - in form { code: x, name: y, scheme: z }, confidentiality codes for the document along with its display name and coding scheme
#  event - in form { code: x, name: y, scheme: z }, clinical event codes that represent the main clinical acts for the document along with its display name and coding scheme
#  format - in form { code: x, name: y, scheme: z }, the format of the document, its specific structure
#  healthcareFacilityType - in form { code: x, name: y, scheme: z }, the facility in which the encounter captured in the document occured
#  practiceSetting - in form { code: x, name: y, scheme: z }, the clinical specialty where the act that resulted in the document was performed
#  type - in form { code: x, name: y, scheme: z }, the precise type of the document form the user perspective
#  authorSlots - an array of Slot objects that contain author details, see ITI techinical framework section 4.2.3.1.4
###
exports.DocumentEntry = class DocumentEntry
  constructor: (entryUUID, mimeType, availabilityStatus, hash, size, languageCode, repositoryUniqueId, sourcePatientId, patientId, uniqueId, creationTime, clazz, confidentiality, event, format, healthcareFacilityType, practiceSetting, type, authorSlots) ->
    @['@'] =
      'id': entryUUID
      'mimeType': mimeType
      'objectType': 'urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1'
      'status': availabilityStatus

    @Slot = []

    @Slot.push new Slot('hash', hash) if hash?
    @Slot.push new Slot('size', size) if size?
    @Slot.push new Slot('languageCode', languageCode) if languageCode?
    @Slot.push new Slot('repositoryUniqueId', repositoryUniqueId) if repositoryUniqueId?
    @Slot.push new Slot('sourcePatientId', sourcePatientId) if sourcePatientId?
    @Slot.push new Slot('creationTime', creationTime) if creationTime?
    
    @Classification = []

    # DocumentEntry.classCode
    if clazz?
      @Classification.push new Classification(
        clazz.name,
        'urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a',
        entryUUID,
        clazz.code,
        null,
        new Slot('codingScheme', clazz.scheme)
      )
    # DocumentEntry.confidentialityCode
    if confidentiality?
      @Classification.push new Classification(
        confidentiality.name,
        'urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f',
        entryUUID,
        confidentiality.code,
        null,
        new Slot('codingScheme', confidentiality.scheme)
      )
    # DocumentEntry.eventCodeList
    if event?
      @Classification.push new Classification(
        event.name,
        'urn:uuid:2c6b8cb7-8b2a-4051-b291-b1ae6a575ef4',
        entryUUID,
        event.code,
        null,
        new Slot('codingScheme', event.scheme)
      )
    # DocumentEntry.formatCode
    if format?
      @Classification.push new Classification(
        format.name,
        'urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d',
        entryUUID,
        format.code,
        null,
        new Slot('codingScheme', format.scheme)
      )
    if healthcareFacilityType?
    # DocumentEntry.healthcareFacilityTypeCode
      @Classification.push new Classification(
        healthcareFacilityType.name,
        'urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1',
        entryUUID,
        healthcareFacilityType.code,
        null,
        new Slot('codingScheme', healthcareFacilityType.scheme)
      )
    # DocumentEntry.practiceSettingCode
    if practiceSetting?
      @Classification.push new Classification(
        practiceSetting.name,
        'urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead',
        entryUUID,
        practiceSetting.code,
        null,
        new Slot('codingScheme', practiceSetting.scheme)
      )
    # DocumentEntry.typeCode
    if type?
      @Classification.push new Classification(
        type.name,
        'urn:uuid:f0306f51-975f-434e-a61c-c59651d33983',
        entryUUID,
        type.code,
        null,
        new Slot('codingScheme', type.scheme)
      )
    # DocumentEntry.author
    if authorSlots?
      authorClass = new Classification(
        null,
        'urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d',
        entryUUID,
        null,
        null
      )
      for slot in authorSlots
        authorClass.addSlot slot
      @Classification.push authorClass
    
    @ExternalIdentifier = []

    if patientId?
      @ExternalIdentifier.push new ExternalIdentifier(
        'XDSDocumentEntry.patientId',
        'urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427',
        entryUUID,
        patientId
      )
    if uniqueId?
      @ExternalIdentifier.push new ExternalIdentifier(
        'XDSDocumentEntry.uniqueId',
        'urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab',
        entryUUID,
        uniqueId
      )

###
# SubmissionSet.
#   entryUUID - in form 'urn:uuid:a6e06ca8-0c75-4064-9e5c-88b9045a96f6'
#   avalabilityStatus - urn:oasis:names:tc:ebxml-regrep:StatusType:Approved or urn:oasis:names:tc:ebxml-regrep:StatusType:Deprecated
#   submissionTime - the point in time that the submission set was submitted in DTM format (YYYY[MM[DD[hh[mm[ss]]]]] in UTC time) eg. 20050102030405
#   patientId - the patient id in the XDS affinity domain in CX form eg. 6578946^^^&amp;1.3.6.1.4.1.21367.2005.3.7&amp;ISO
#   sourceId - the globally unique id of the entity that contributed the SubmissionSet, in OID format
#   uniqueId - the globallly unique id of this submission set in OID format
#   contentType - in form { code: x, name: y, scheme: z }, the type of clinical activity that resulted in these documents
#   authorSlots - an array of Slot objects that contain author details, see ITI techinical framework section 4.2.3.1.4
###
exports.SubmissionSet = class SubmissionSet
  constructor: (entryUUID, avalabilityStatus, submissionTime, patientId, sourceId, uniqueId, contentType, authorSlots) ->
    @['@'] =
      'id': entryUUID
      'status': avalabilityStatus

    @Slot = []

    @Slot.push new Slot('submissionTime', submissionTime) if submissionTime

    @Classification = []

    # SubmissionSet.contentTypeCode
    if contentType
      @Classification.push new Classification(
        contentType.name,
        'urn:uuid:aa543740-bdda-424e-8c96-df4873be8500',
        entryUUID,
        contentType.code,
        null,
        new Slot('codingScheme', contentType.scheme)
      )
    # SubmissionSet.author
    if authorSlots?
      authorClass = new Classification(
        null,
        'urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d',
        entryUUID,
        null,
        null
      )
      for slot in authorSlots
        authorClass.addSlot slot
      @Classification.push authorClass
    
    @ExternalIdentifier = []

    if patientId
      @ExternalIdentifier.push new ExternalIdentifier(
        'XDSSubmissionSet.patientId',
        'urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446',
        entryUUID,
        patientId)
    if sourceId
      @ExternalIdentifier.push new ExternalIdentifier(
        'XDSSubmissionSet.sourceId',
        'urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832',
        entryUUID,
        sourceId)
    if uniqueId
      @ExternalIdentifier.push new ExternalIdentifier(
        'XDSSubmissionSet.uniqueId',
        'urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8',
        entryUUID,
        uniqueId)

exports.Association = class Association
  constructor: (type, srcObj, targetObj, slot) ->
    @['@'] =
      'associationType': type
      'id': 'urn:uuid:c9abae3c-688f-4505-a136-bd99ca5019fb'
      'sourceObject': srcObj
      'targetObject': targetObj
    @Slot = slot

exports.Document = class Document
  constructor: (id, href) ->
    @['@'] =
      'id': id
    @['xop:Include'] =
      '@':
        'xmlns:xop': 'http://www.w3.org/2004/08/xop/include'
        'href': href

exports.SoapHeader = class SoapHeader
  constructor: (MessageID) ->
    @['@'] =
      'xmlns:a': 'http://www.w3.org/2005/08/addressing'
    @['a:Action'] =
      '@':
        'soap:mustUnderstand': 'true'
      '#': 'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b'
    @['a:To'] =
      '@':
        'soap:mustUnderstand': 'true'
      '#': 'https://localhost:5000/xdsrepository'
    @['a:MessageID'] = MessageID
    @['a:ReplyTo'] =
      '@':
        'soap:mustUnderstand': 'true'
      'a:Address': 'http://www.w3.org/2005/08/addressing/anonymous'

###
# Produces a PNRRequest with the document element's href = <DocumentEntry.id>@ihe.net (minus the 'urn:uuid:' prefix if there is one)
###
exports.ProvideAndRegisterDocumentSetRequest = class ProvideAndRegisterDocumentSetRequest
  constructor: (documentEntries, submissionSet) ->
    @['@'] =
      'xmlns': 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'
      'xmlns:xds': 'urn:ihe:iti:xds-b:2007'
      'xmlns:lcm': 'urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0'
      'xmlns:query': 'urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0'
      'xmlns:rs': 'urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0'
    @['lcm:SubmitObjectsRequest'] =
      'RegistryObjectList':
        'ExtrinsicObject': []
        'RegistryPackage': submissionSet
        # Classisify registry package as a submission set
        'Classification': new Classification(
          null,
          null,
          submissionSet['@'].id,
          null,
          'urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd',
          null)
        'Association': []
        'Document': []

    for documentEntry in documentEntries
      @['lcm:SubmitObjectsRequest'].RegistryObjectList.ExtrinsicObject.push documentEntry
      @['lcm:SubmitObjectsRequest'].RegistryObjectList.Association.push new Association(
        'urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember',
        submissionSet['@'].id,
        documentEntry['@'].id,
        new Slot('SubmissionSetStatus', 'Original')
      )
      @['lcm:SubmitObjectsRequest'].RegistryObjectList.Document.push new Document(
        documentEntry['@'].id,
        'cid:' + documentEntry['@'].id.replace('urn:uuid:', '') + '@ihe.net'
      )


exports.SoapEnvelope = class SoapEnvelope
  constructor: (ProvideAndRegisterDocumentSetRequest) ->
    @['@'] =
      'xmlns:soap': 'http://www.w3.org/2003/05/soap-envelope'
    @['soap:Header'] = new SoapHeader(uuid.v4())
    @['soap:Body'] =
      'xds:ProvideAndRegisterDocumentSetRequest': ProvideAndRegisterDocumentSetRequest
