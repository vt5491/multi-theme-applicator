LocalThemeSelectorView = require '../lib/local-theme-selector-view'
MultiThemeApplicator = require '../lib/multi-theme-applicator'
LocalThemeManager = require '../lib/local-theme-manager'

describe 'LocalThemeSelectorView', () ->
  localThemeSelectorView: null
  activationPromise: null

  beforeEach ->
    #@activationPromise = atom.packages.activatePackage('multi-theme-applicator');

    #vt add
    #waitsForPromise( => @activationPromise)
    # waitsForPromise ->
    #   atom.packages.activatePackage('multi-theme-applicator');
    #
    # runs ->
    #   @multiThemeApplicator = atom.packages.getActivePackage('multi-theme-applicator')
    #vt end
    #vt add
    #@multiThemeApplicator =  MultiThemeApplicator.activate()
    #@multiThemeApplicatorSpy = spyOn
    #vt end
    #activationPromise = atom.packages.activatePackage('multi-theme-applicator');
    #vt@localThemeSelectorView = new LocalThemeSelectorView()
    # this is pretty ugly, but we have to do this since 'local-theme-selector-view'
    # needs to call certain methods in the package.  The package is a module and
    # not a normal class.
    @multiThemeApplicatorMock = {
      toggle: ->
        "do nothing"
    }

    @localThemeSelectorView = new LocalThemeSelectorView(@multiThemeApplicatorMock)
    #vt add
    #)
    #vt end

  it 'ctor works', () ->
    #vt add
    # waitsForPromise( => @activationPromise)
    #
    # runs( =>
    #vt end
    expect(@localThemeSelectorView.localThemeManager).toBeDefined()
    expect(@localThemeSelectorView.localThemeManager).toBeInstanceOf(LocalThemeManager)
    #vt add
    #)
    #vt end

  it 'doIt works', () ->
    expect(@localThemeSelectorView.doIt()).toEqual 7

  it 'getCurrentGlobalSyntaxTheme works', () ->
    currentTheme = @localThemeSelectorView.getCurrentGlobalSyntaxTheme()
