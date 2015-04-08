mhd2xds = require '../lib/mhd2xds'

describe 'mhs2xds unit tests', ->

  it 'should convert mhd v1 metadata to xds.b metadata', ->
    xds = mhd2xds.mhd1Metadata2Xds null
    console.log xds