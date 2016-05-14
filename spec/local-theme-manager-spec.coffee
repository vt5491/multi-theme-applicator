LocalThemeManager = require '../lib/local-theme-manager'

describe 'LocalThemeManager', () ->
  beforeEach ->
    @localThemeManager = new LocalThemeManager()

    # spyOn(atom.packages, "getActivePackages").and.returnValue([1, 2 ,3])
    packageManager = atom.packages
    # console.log('beforeEach: packageManager.getActivePackages=' + packageManager.getActivePackages)
    mySpy = spyOn(packageManager, "getActivePackages")
    mySpy.andReturn([ { metadata: { theme: "syntax", name: "test-syntax-theme"}}])
    # console.log('beforeEach: mySpy=' + mySpy)
    # spyOn(foo, "getBar").and.callFake(function() {
    #   return 1001;
    # });

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
