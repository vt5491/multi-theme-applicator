MultiThemeApplicator = require '../lib/multi-theme-applicator'

describe 'MultiThemeApplicator-main', () ->
  multiThemeApplicator: null

  beforeEach ->

  it 'doIt works', () ->
    expect(MultiThemeApplicator.doIt()).toEqual 7
