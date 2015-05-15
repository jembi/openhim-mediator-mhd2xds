js2xml = require 'js2xmlparser'
uuid = require 'uuid'
dom = require('xmldom').DOMParser
xpath = require 'xpath'
xds = require './xds'

exports.mhd1Metadata2XdsForMomconnect = (metadata, cda) ->
  cda = cda.trim()
  doc = new dom().parseFromString(cda)

  select = xpath.useNamespaces
    'v3': 'urn:hl7-org:v3'

  birthDate = select 'string(//v3:ClinicalDocument/v3:recordTarget/v3:patientRole/v3:patient/v3:birthTime/@value)', doc
  birthDate = birthDate.replace '%', ''

  authorPersonId = select 'string(//v3:ClinicalDocument/v3:author/v3:assignedAuthor/v3:assignedPerson/../v3:id/@extension)', doc
  if authorPersonId.length is 0 then authorPersonId = 'unknown'
  authorPersonAssigningAuthorityId = select 'string(//v3:ClinicalDocument/v3:author/v3:assignedAuthor/v3:assignedPerson/../v3:id/@root)', doc

  authorMachineId = select 'string(//v3:ClinicalDocument/v3:author/v3:assignedAuthor/v3:assignedAuthoringDevice/../v3:id/@extension)', doc
  if authorMachineId.length is 0 then authorMachineId = 'unknown'
  authorMachineAssigningAuthorityId = select 'string(//v3:ClinicalDocument/v3:author/v3:assignedAuthor/v3:assignedAuthoringDevice/../v3:id/@root)', doc
  authorMachineSoftwareName = select 'string(//v3:ClinicalDocument/v3:author/v3:assignedAuthor/v3:assignedAuthoringDevice/v3:softwareName)', doc

  gender = select 'string(//v3:ClinicalDocument/v3:recordTarget/v3:patientRole/v3:patient/v3:administrativeGenderCode/@code)', doc

  now = new Date() # YYYY[MM[DD[hh[mm[ss]]]]]
  year = now.getUTCFullYear()
  month = now.getUTCMonth() + 1
  if month < 10
    month = '0' + month
  day = now.getUTCDate()
  if day < 10
    day = '0' + day
  hours = now.getUTCHours()
  if hours < 10
    hours = '0' + hours
  minutes = now.getUTCMinutes()
  if minutes < 10
    minutes = '0' + minutes
  seconds = now.getUTCSeconds()
  if seconds < 10
    seconds = '0' + seconds
  now = "#{year}#{month}#{day}#{hours}#{minutes}#{seconds}"

  patientIdCx = metadata.documentEntry.patientId
  patientId = patientIdCx.substring(0, patientIdCx.indexOf('^'))
  patientIdType = patientIdCx.substring(patientIdCx.indexOf('^^^')+3, patientIdCx.lastIndexOf('^'))
  patientIdAssigningAuthority = patientIdCx.substring(patientIdCx.lastIndexOf('^')+1)
  sourceId = "#{patientId}^^^&#{patientIdType}-#{patientIdAssigningAuthority}-526ef9c3-6f18-420a-bc53-9b733920bc67&ISO"

  authorPersonSlot = new xds.Slot 'authorPerson', "#{authorPersonId}^^^^^^^^&#{authorPersonAssigningAuthorityId}&ISO"
  authorMachineSlot = new xds.Slot 'authorPerson', "#{authorMachineId}^#{authorMachineSoftwareName}^^^^^^^&#{authorMachineAssigningAuthorityId}&ISO"

  docEntry = new xds.DocumentEntry(
    metadata.documentEntry.entryUUID,
    metadata.documentEntry.mimeType,
    'urn:oasis:names:tc:ebxml-regrep:StatusType:Approved',
    metadata.documentEntry.hash,
    metadata.documentEntry.size,
    'en-ZA',
    null, # repositoryUniqueId
    sourceId # sourcePatientId
    sourceId,
    metadata.documentEntry.uniqueId,
    now, # creationTime
    {
      code: metadata.documentEntry.classCode.code,
      scheme: metadata.documentEntry.classCode.codingScheme,
      name: metadata.documentEntry.classCode.codeName
    },
    null, # confidentiality
    null, # event
    {
      code: metadata.documentEntry.formatCode.code,
      scheme: metadata.documentEntry.formatCode.codingScheme,
      name: metadata.documentEntry.formatCode.codeName
    },
    null, # healthcareFacilityType
    null, # practiceSetting
    {
      code: metadata.documentEntry.typeCode.code,
      scheme: metadata.documentEntry.typeCode.codingScheme,
      name: metadata.documentEntry.typeCode.codeName
    },
    [authorPersonSlot, authorMachineSlot] # authorSlots
  )

  # sourcePatientId slot
  slot = new xds.Slot 'sourcePatientInfo',
    "PID-3|#{sourceId}",
    'PID-5|Unknown^Unknown^^^',
    "PID-7|#{birthDate}"
    "PID-8|#{gender}"
  docEntry.addSlot slot

  submissionSet = new xds.SubmissionSet(
    uuid.v4(), # entryUUID
    'urn:oasis:names:tc:ebxml-regrep:StatusType:Approved',
    now,
    metadata.documentEntry.patientId,
    null, # sourceId
    uuid.v4(),
    null, # contentType
    [authorPersonSlot, authorMachineSlot] # authorSlots
  )

  pnrReq = new xds.ProvideAndRegisterDocumentSetRequest [docEntry], submissionSet
  return (new xds.SoapEnvelope pnrReq).toXml()

exports.mhd2Metadata2Xds = (metadata) ->
  throw new Error 'Not implemented'
