LocalThemeManager = require '../lib/local-theme-manager'
Utils = require '../lib/utils'
Base = require '../lib/base'
$ = jQuery = require 'jquery'
fs = require 'fs'
path = require 'path'

# A helper method to setup '<atom-text-editor>' test enviornment.
# We call this core environment, and then add or subtract from it in
# each describe block.
buildEditorTestEvironment = () ->
  textEditor = atom.workspace.buildTextEditor()

  # create some "pad" style elements that precede the the theme's style element
  # we use 'spellCheck' and 'gutter' just because these are two actual shadowRootatomStyles
  # that are attached to text-editor
  spellCheckStyle = document.createElement('style')
  spellCheckStyle.setAttribute('source-path', '/tmp/.atom/packages/spellCheck/index.less')
  spellCheckStyle.setAttribute('priority', '0')

  gutterStyle = document.createElement('style')
  gutterStyle.setAttribute('source-path', '/tmp/.atom/packages/gutter/gutter.less')
  gutterStyle.setAttribute('priority', '0')

  themeStyle = document.createElement('style')
  themeStyle.setAttribute('source-path', '/tmp/.atom/packages/test-theme/index.less')
  themeStyle.setAttribute('priority', '1')

  textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor")
  .andReturn(textEditor)

  # return to caller so they can then use in "expect" statements
  textEditor

describe 'LocalThemeManager', () ->
  beforeEach ->
    @localThemeManager = new LocalThemeManager()
    @utils = new Utils()

    packageManager = atom.packages
    mySpy = spyOn(packageManager, "getActivePackages")
    mySpy.andReturn([ { metadata: { theme: "syntax", name: "test-syntax-theme"}}])

    textEditor = atom.workspace.buildTextEditor()
    atom.workspace.buildTextEditor()
    themeStyle = document.createElement('style')
    themeStyle.setAttribute('source-path', '/tmp/.atom/packages/test-theme/index.less')

    textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor")
      .andReturn(@textEditor)

  it 'ctor works', () ->
    expect(@localThemeManager.utils).toBeInstanceOf(Utils)

  it 'doIt works', () ->
    atom.packages.getActivePackages()
    expect(@localThemeManager.doIt()).toEqual 7

  it 'getActiveSyntaxTheme returns proper theme', () ->
    expect(@localThemeManager.getActiveSyntaxTheme()).toEqual("test-syntax-theme")

  xit 'getThemeCss does promises correctly', () ->
    # hook fs.readFile to return a string without doing io
    cssSnippet = """
atom-text-editor, :host {
  background-color: #e3d5c1;
  color: #000000;
    """
    spyOn(fs, "readFile").andReturn(cssSnippet)

    promise = @localThemeManager.getThemeCss('/home/vturner/.atom/packages/humane-syntax')

    expect(promise).toBeInstanceOf(Promise)

    cssResult = null

    promise
      .then(
        (result) ->
          cssResult = result
          expect(cssResult).not.toBeNull()
        ,(err) ->
          console.log "promise returner err" + err
      )

# here we test a more "real" style tree attached to the mock editor
describe 'LocalThemeManager with complex atom-text-editor style tree', () ->
  beforeEach ->
    @localThemeManager = new LocalThemeManager()
    @utils = new Utils()

    packageManager = atom.packages
    mySpy = spyOn(packageManager, "getActivePackages")
    mySpy.andReturn([ { metadata: { theme: "syntax", name: "test-syntax-theme"}}])

    @textEditor = buildEditorTestEvironment()

  it 'addStyleElementToHead', () ->
    styleElem = document.createElement('style')

    # editor scope
    styleClass = @localThemeManager.addStyleElementToHead styleElem, 'editor'

    # verify it's now there
    elem = $('head').find("atom-styles .#{styleClass}")[0]
    expect(elem).toBeTruthy()
    expect(elem.getAttribute('class').match(/editor/)).toBeTruthy()

    # pane scope
    styleClass = @localThemeManager.addStyleElementToHead styleElem, 'pane'

    # verify it's now there
    elem = $('head').find("atom-styles .#{styleClass}")[0]
    expect(elem).toBeTruthy()
    expect(elem.getAttribute('class').match(/pane/)).toBeTruthy()

  # this is too hard to unit-test.  The code is expecting the bg color to be
  # at this location:
  #bgColor = node3[0].sheet.rules[0].style.backgroundColor
  # and I don't want to set that up
  xit 'syncEditorBackgroundColor works', () ->
    console.log('syncEditorBackgroundColor: @textEditor=' + @textEditor)

describe "LocalThemeManager getSyntaxThemeLookup tests", () ->
   packageMetadataMock = []
   packageMetadataMock.push {name: 'atom-beautify'}
   packageMetadataMock.push {name: 'choco', theme: 'syntax'}
   packageMetadataMock.push {name: 'humane-syntax', theme: 'syntax'}

   packagePathsMock = []
   packagePathsMock.push "/home/user/.atom/packages/atom-beautify"
   packagePathsMock.push "/home/user/.atom/packages/choco"
   packagePathsMock.push "/home/user/.atom/packages/humane-syntax"

   beforeEach ->
     @localThemeManager = new LocalThemeManager()
     @textEditor = atom.workspace.buildTextEditor()

     spyOn(atom.packages, "getAvailablePackageMetadata")
       .andReturn(packageMetadataMock)
     spyOn(atom.packages, "getAvailablePackagePaths")
       .andReturn(packagePathsMock)

   it 'getSyntaxThemeLookup works', ->
     result = @localThemeManager.getSyntaxThemeLookup()

     expect(result).toBeInstanceOf(Array)
     expect(result.length).toEqual(2)
     expect(result[0].themeName).toEqual("choco")
     expect(result[0].baseDir).toEqual("/home/user/.atom/packages/choco")

   it 'narrowStyleScope works with two line css selector', ->
     styleKey = 'abc'

     # two-line selector with ':host' keyword
     # atom-text-editor flavor
     css = """
atom-text-editor,
:host {
  background-color: #212020;
  color: #fff0ed;
}
.syntax--comment {
  color: #7C7C7C;
}
     """

     expectedCssFrag_1 = "atom-text-editor.#{styleKey}.editor"
     re_1 = new RegExp(expectedCssFrag_1, 'gm')

     expectedCssFrag_2 = ".#{styleKey}.editor .syntax--comment"
     re_2 = new RegExp(expectedCssFrag_2, 'gm')

     result = @localThemeManager.narrowStyleScope(css, styleKey, "file")

     expect(result.match re_1).toBeTruthy()
     expect(result.match re_2).toBeTruthy()

     # pane level test
     expectedCssFrag = ".#{styleKey} atom-text-editor"

     result = @localThemeManager.narrowStyleScope(css, styleKey, "pane")

     re = new RegExp(expectedCssFrag, 'gm')
     expect(result.match re).toBeTruthy()

   it 'narrowStyleScope works with one line css selector', ->
     styleKey = 'abc'

     # one line selector
     css = """
atom-text-editor .gutter {
  color: #959595;
}
     """

     expectedCss = """
atom-text-editor.#{styleKey}.editor .gutter {
  color: #959595;
}
     """

     result = @localThemeManager.narrowStyleScope(css, styleKey, 'editor')

     expect(result).toEqual(expectedCss)

   it 'narrowStyleScope works with "syntax--" keyword', ->
     styleKey = 'abc'

     # one line selector
     css = """
.syntax--comment {
  color: #ff79c6;
}
     """

     expectedCss = """
.#{styleKey} .syntax--comment {
  color: #ff79c6;
}
     """

     result = @localThemeManager.narrowStyleScope(css, styleKey, 'pane')

     expect(result).toEqual(expectedCss)

   it 'removeStyleElementFromHead works', ->
     styleClass = 'mta-editor-style-1234567890123'

     $('head atom-styles .' + styleClass).remove()

     headStyleElement = document.createElement('style')

     headStyleElement.setAttribute('context', 'atom-text-editor' )
     headStyleElement.setAttribute('class', styleClass )

     $.find('head atom-styles')[0].appendChild(headStyleElement)

     # verify it's there before we delete
     expect($.find("head atom-styles style.#{styleClass}").length).toEqual(1)

     # and now verify it was deleted
     @localThemeManager.removeStyleElementFromHead styleClass
     expect($.find("head atom-styles style.#{styleClass}").length).toEqual(0)

     # idempotency test: verify there are no problems when remove is called
     # multiple times
     expect($.find("head atom-styles style.#{styleClass}").length).toEqual(0)

   it 'getCssBgColor returns the proper background-color', ->
    css = """
/* Dracula Theme
 *
 * https://github.com/dracula/atom
 *
 * Copyright 2016, All rights reserved
 *
 * Code licensed under the MIT license
 * https://github.com/dracula/atom/blob/master/LICENSE
 *
 * @author Zeno Rocha <hi@zenorocha.com>
 */
atom-text-editor,
atom-text-editor .gutter {
  background-color: #282a36;
  color: #f8f8f2;
}
atom-text-editor.is-focused .cursor {
  border-color: #f8f8f0;
}
atom-text-editor.is-focused .selection .region {
  background-color: #44475a;
}
atom-text-editor.is-focused .line-number.cursor-line-no-selection,
atom-text-editor.is-focused .line.cursor-line {
  background-color: #44475a;
}
    """
    result = @localThemeManager.getCssBgColor css
    expect(result).toEqual("#282a36")

    # make sure it handles a non-matching case gracefully
    css = "nada match"
    result = @localThemeManager.getCssBgColor css
    expect(result).toBeNull()

    # upper case hex test
    css = """
atom-text-editor,
:host {
  background-color: #5A5475;
  color: #F8F8F2;
}
atom-text-editor .gutter,
:host .gutter {
  background-color: #5A5475;
  color: #F8F8F2;
}
"""

    result = @localThemeManager.getCssBgColor css
    expect(result).toEqual("#5A5475")

   it 'normalizeSyntaxScope properly add .syntax-- to non atom 1.13 compatible themes', ->

     css = """
atom-text-editor,
:host {
  background-color: #212020;
  color: #fff0ed;
}
.comment {
  color: #7C7C7C;
}
     """

    #  debugger
     result = @localThemeManager.normalizeSyntaxScope css

     # lines with 'atom' should be unaffected
     expectedCssFrag = "^atom-text-editor,"
     re = new RegExp(expectedCssFrag, 'gm')

     expect(result.match re).toBeTruthy()

     # non-atom elements should have 'syntax--' format
     expectedCssFrag = "^.syntax--comment"
     re = new RegExp(expectedCssFrag, 'gm')

     expect(result.match re).toBeTruthy()

describe "LocalThemeManager scoped theme removal tests", () ->

  beforeEach ->
    @localThemeManager = new LocalThemeManager()

    # setup textEditors
    @textEditor_1 = atom.workspace.buildTextEditor()
    # atom.workspace.buildTextEditor()

    @textEditor_2 = atom.workspace.buildTextEditor()

    textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor")
      .andReturn(@textEditor_1)

    # mock up an 'atom-text-editor' element
    @styleClass_editor = 'mta-editor-style-1234567890123'
    @styleClass_file = 'mta-file-style-1234567890123'

    $editorElem_1 = $('<atom-text-editor></atom-text-editor')
    $editorElem_1.attr('class', @styleClass_editor)
    $editorElem_1.addClass(@styleClass_file)
    editorElem_1 = $editorElem_1[0]
    spyOn(@textEditor_1, "getElement").andReturn(editorElem_1)
    spyOn(@textEditor_1, "getURI").andReturn("/mydir/abc.txt")

    $editorElem_2 = $('<atom-text-editor></atom-text-editor')
    $editorElem_2.attr('class', @styleClass_file)
    editorElem_2 = $editorElem_2[0]
    spyOn(@textEditor_2, "getElement").andReturn(editorElem_2)
    spyOn(@textEditor_2, "getURI").andReturn("/mydir/abc.txt")
    # setup Base.ElementLookup
    Base.ElementLookup.set @textEditor_1, {"editor" : {'styleClass' : @styleClass_editor} }
    Base.ElementLookup.get(@textEditor_1)['file'] = {'styleClass' : @styleClass_file}

    Base.ElementLookup.set @textEditor_2, {"file" : {'styleClass' : @styleClass_file} }

    # Setup head style element
    headStyleElement_editor = document.createElement('style')
    headStyleElement_file = document.createElement('style')

    headStyleElement_editor.setAttribute('context', 'atom-text-editor' )
    headStyleElement_editor.setAttribute('class', @styleClass_editor )

    headStyleElement_file.setAttribute('class', @styleClass_file )

    # We have to manually remove from head since beforeEach doesn't automatically
    # clean up the DOM.
    $('head atom-styles .' + @styleClass_editor).remove()
    $('head atom-styles .' + @styleClass_file).remove()

    $('head atom-styles ').append(headStyleElement_editor)
    $('head atom-styles').append(headStyleElement_file)

    editors = []
    editors.push @textEditor_1
    editors.push @textEditor_2

    spyOn(atom.workspace, 'getTextEditors').andReturn(editors)

  it 'removeScopedTheme removes the theme properly from an editor', ->
    @localThemeManager.removeScopedTheme('editor')

    # verify head element removed
    expect($('head').find(".#{@styleClass_editor}").length ).toEqual(0)
    expect($('head').find(".#{@styleClass_file}").length > 0 ).toBeTruthy()

    #verify element class is removed
    expect($("atom-text-editor.#{@styleClass_editor}").length).toEqual(0)

  it 'removeScopedTheme removes the theme properly from a file scope', ->
    @localThemeManager.removeScopedTheme('file')

    # verify head element removed
    expect($('head').find(".#{@styleClass_editor}").length ).toEqual(1)
    expect($('head').find(".#{@styleClass_file}").length).toEqual(0)

    #verify element class is removed
    expect($("atom-text-editor.#{@styleClass_file}").length).toEqual(0)
