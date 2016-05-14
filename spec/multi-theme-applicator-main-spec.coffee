MultiThemeApplicator = require '../lib/multi-theme-applicator'
# `import ThemeSelectorView from '../lib/theme-selector-view'`

describe 'MultiThemeApplicator-main', () ->
  multiThemeApplicator: null

  beforeEach ->
    # @multiThemeApplicator =
    # @multiThemeApplicator = new MultiThemeApplicator()

  it 'doIt works', () ->
    # expect(@multiThemeApplicator.doIt()).toEqual 7
    expect(MultiThemeApplicator.doIt()).toEqual 7
