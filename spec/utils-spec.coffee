Utils = require '../lib/utils'

fdescribe 'Utils', () ->
  beforeEach ->
    @utils = new Utils()

  it 'doIt works', () ->
    expect(@utils.doIt()).toEqual 7
