LocalThemeSelectorView = require '../lib/local-theme-selector-view'
MultiThemeApplicator = require '../lib/multi-theme-applicator'
LocalThemeManager = require '../lib/local-theme-manager'

describe 'LocalThemeSelectorView', () ->
  localThemeSelectorView: null
  activationPromise: null

  beforeEach ->
    @activationPromise = atom.packages.activatePackage('multi-theme-applicator');
    @localThemeSelectorView = new LocalThemeSelectorView()

  it 'ctor works', () ->
    expect(@localThemeSelectorView.localThemeManager).toBeDefined()
    expect(@localThemeSelectorView.localThemeManager).toBeInstanceOf(LocalThemeManager)

  it 'doIt works', () ->
    expect(@localThemeSelectorView.doIt()).toEqual 7

  it 'getCurrentGlobalSyntaxTheme works', () ->
    currentTheme = @localThemeSelectorView.getCurrentGlobalSyntaxTheme()
