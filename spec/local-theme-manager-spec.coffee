LocalThemeManager = require '../lib/local-theme-manager'
Utils = require '../lib/utils'
$ = jQuery = require 'jquery'

fdescribe 'LocalThemeManager', () ->
  beforeEach ->
    @localThemeManager = new LocalThemeManager()
    @utils = new Utils()

    # spyOn(atom.packages, "getActivePackages").and.returnValue([1, 2 ,3])
    packageManager = atom.packages
    # console.log('beforeEach: packageManager.getActivePackages=' + packageManager.getActivePackages)
    mySpy = spyOn(packageManager, "getActivePackages")
    mySpy.andReturn([ { metadata: { theme: "syntax", name: "test-syntax-theme"}}])

    textEditor = atom.workspace.buildTextEditor()
    # textEditorEl = textEditor.getElement()
    # shadowRoot = document.createElement("shadow-root")
    #
    # atomStyles = document.createElement('atom-styles')
    # # shadowRootatomStyles = document.createElement('atom-styles')appendChild()
    # #
    themeStyle = document.createElement('style')
    themeStyle.setAttribute('source-path', '/tmp/.atom/packages/test-theme/index.less')
    #
    # atomStyles.appendChild(themeStyle)
    # shadowRoot.appendChild(atomStyles)
    #
    # textEditorEl = {'thadowRoot': shadowRoot}
    #
    # #dummyElement = document.createElement('div');
    # #document.getElementById = jasmine.createSpy('HTML Element').andReturn(dummyElement);
    # textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor")
    # textEditorSpy.andReturn(textEditor)
    # console.log('LocalThemeManager.beforeEach: getActiveTextEditor()=' + atom.workspace.getActiveTextEditor())
    # textEditor.getElement().shadowRoot.querySelector('atom-styles')
    textEditor.getElement().shadowRoot.querySelector('atom-styles').appendChild(themeStyle)

    textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor")
      .andReturn(textEditor)

  it 'ctor works', () ->
    console.log('utils=' + @localThemeManager.utils)
    expect(@localThemeManager.utils).toBeInstanceOf(Utils)

  it 'doIt works', () ->
    console.log('local-theme-manager-spec.doIt: testing doIt')

    # console.log('local-theme-manager-spec.doIt: getActivePackages=' + atom.packages.getActivePackages)
    atom.packages.getActivePackages()
    # toHaveBeenCalled();
    expect(@localThemeManager.doIt()).toEqual 7
    # expect(@localThemeManager.doIt()).toEqual 7

  it 'getActiveSyntaxTheme returns proper theme', () ->
    # expect(atom.packages.getActivePackages).toHaveBeenCalled()
    expect(@localThemeManager.getActiveSyntaxTheme()).toEqual("test-syntax-theme")

  fit 'deleteThemeNode works', () ->
    console.log('local-theme-manager-spec: testing deleteThemeNode')
    @localThemeManager.deleteThemeNode()

    shadowRoot = @utils.getActiveShadowRoot()
    expect($(shadowRoot).find('atom-styles').find('style')).not.toExist()
