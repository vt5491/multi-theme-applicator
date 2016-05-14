LocalStylesElement = require '../lib/local-styles-element'

describe 'LocalStylesElement', () ->

  localStylesElement: null

  beforeEach ->
    @localStylesElement = new LocalStylesElement()

  it 'doIt works', () ->
    expect(@localStylesElement.doIt()).toEqual 7
