Base = require '../lib/base'

describe 'Base', () ->

  it 'class variables are defined', () ->
    expect(Base.ElementLookup).toBeTruthy()
    expect(Base.ThemeLookup).toBeTruthy()
    expect(Base.FileTypeLookup).toBeTruthy()
