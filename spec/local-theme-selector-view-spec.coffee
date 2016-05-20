LocalThemeSelectorView = require '../lib/local-theme-selector-view'
MultiThemeApplicator = require '../lib/multi-theme-applicator'
LocalThemeManager = require '../lib/local-theme-manager'
# `import ThemeSelectorView from '../lib/theme-selector-view'`

describe 'LocalThemeSelectorView', () ->
  localThemeSelectorView: null
  activationPromise: null

  beforeEach ->
    console.log "theme-selector-view-spec.beforeEach: entered"
    # @activationPromise = atom.packages.activatePackage('theme-selector-view');
    @activationPromise = atom.packages.activatePackage('multi-theme-applicator');
    console.log "theme-selector-view-spec.beforeEach: activationPromise=" + @activationPromise
    @localThemeSelectorView = new LocalThemeSelectorView()
    console.log "theme-selector-view-spec.beforeEach: localThemeSelectorView=" + @localThemeSelectorView
    # waitsForPromise ->
    #   @activationPromise
      # atom.packages.activatePackage('multi-theme-applicator').then (obj) ->
      #   console.log "obj=" + obj

    # console.log "theme-selector-view-spec.beforeEach: back from promise"
    # mock up packages.getActivePackages (packages is a package-manager)

  it 'ctor works', () ->
    #expect(@localThemeSelectorView.localThemeManager).not.toExist()
    expect(@localThemeSelectorView.localThemeManager).toBeDefined()
    expect(@localThemeSelectorView.localThemeManager).toBeInstanceOf(LocalThemeManager)

  it 'doIt works', () ->
    # console.log "theme-selector-view-spec.doIt: themeSelectorView=" + themeSelectorView
    expect(@localThemeSelectorView.doIt()).toEqual 7


      # activePackages = atom.packages.getActivePackages()
  it 'getCurrentGlobalSyntaxTheme works', () ->
    currentTheme = @localThemeSelectorView.getCurrentGlobalSyntaxTheme()
    console.log 'currentTheme=' + currentTheme
    # expect(@themeSelectorView.getCurrentGlobalSyntaxTheme()).toEqual(@globalTheme)
    # waitsForPromise ->
    #   @activationPromise
    #
    # runs ->
    #   console.log 'now in runs'
    #
    # console.log "theme-selector-view-spec.doIt: doIt()=" + @themeSelectorView.doIt()


    # waitsForPromise(() => {
    #   @activationPromise;
    # });
    # expect(themeSelectorView.doIt()).toBe 7
