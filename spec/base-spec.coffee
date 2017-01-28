Base = require '../lib/base'

describe 'Base', () ->

  it 'class variables are defined', () ->
    console.log "Base.ElmentLookup=#{Base.ElementLookup}"
    expect(Base.ElementLookup).toBeTruthy()
