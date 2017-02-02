Base = require '../lib/base'

describe 'Base', () ->

  it 'class variables are defined', () ->
    expect(Base.ElementLookup).toBeTruthy()
