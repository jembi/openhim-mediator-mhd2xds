js2xml = require 'js2xmlparser'
uuid = require 'node-uuid'
xds = require './xds'

exports.mhd1Metadata2Xds = (metadata) ->
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

  docEntry = new xds.DocumentEntry(
    metadata.documentEntry.entryUUID,
    metadata.documentEntry.mimeType,
    'urn:oasis:names:tc:ebxml-regrep:StatusType:Approved',
    metadata.documentEntry.hash,
    metadata.documentEntry.size,
    'en-ZA',
    null, # repositoryUniqueId
    metadata.documentEntry.patientId # sourcePatientId
    metadata.documentEntry.patientId,
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
    [] # authorSlots
  )

  submissionSet = new xds.SubmissionSet(
    uuid.v4(), # entryUUID
    'urn:oasis:names:tc:ebxml-regrep:StatusType:Approved',
    now,
    metadata.documentEntry.patientId,
    null, # sourceId
    uuid.v4(),
    null, # contentType
    [] # authorSlots
  )

  pnrReq = new xds.ProvideAndRegisterDocumentSetRequest [docEntry], submissionSet
  return js2xml 'soap:Envelope', new xds.SoapEnvelope pnrReq

exports.mhd2Metadata2Xds = (metadata) ->
  throw new Error 'Not implemented'
