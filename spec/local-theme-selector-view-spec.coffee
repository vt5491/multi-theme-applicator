LocalThemeSelectorView = require '../lib/local-theme-selector-view'
MultiThemeApplicator = require '../lib/multi-theme-applicator'
LocalThemeManager = require '../lib/local-theme-manager'

fdescribe 'LocalThemeSelectorView', () ->
  localThemeSelectorView: null
  activationPromise: null

  beforeEach ->
    # this is pretty ugly, but we have to do this since 'local-theme-selector-view'
    # needs to call certain methods in the package.  The package is a module and
    # not a normal class.
    @multiThemeApplicatorMock = {
      toggle: ->
        "do nothing"
    }

    @localThemeSelectorView = new LocalThemeSelectorView(@multiThemeApplicatorMock)

  it 'ctor works', () ->
    expect(@localThemeSelectorView.localThemeManager).toBeDefined()
    expect(@localThemeSelectorView.localThemeManager).toBeInstanceOf(LocalThemeManager)
    expect(@localThemeSelectorView.elementLookup).toBeInstanceOf(WeakMap)

  it 'doIt works', () ->
    expect(@localThemeSelectorView.doIt()).toEqual 7

  it 'getCurrentGlobalSyntaxTheme works', () ->
    currentTheme = @localThemeSelectorView.getCurrentGlobalSyntaxTheme()
