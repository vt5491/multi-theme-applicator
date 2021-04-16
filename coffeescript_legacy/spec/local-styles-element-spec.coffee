LocalStylesElement = require '../lib/local-styles-element'
$ = jQuery = require 'jquery'

describe 'LocalStylesElement', () ->

  localStylesElement: null

  beforeEach ->
    @localStylesElement = new LocalStylesElement()

  it 'doIt works', () ->
    expect(@localStylesElement.doIt()).toEqual 7

  it 'createStyleElement works', () ->
    css = """
atom-text-editor, :host {
  background-color: #e3d5c1;
  color: #000000;
    """

    # escape special chars from css string so we can do a regex on
    cssRegexSafe = css.replace(/\{/,'\\{')

    sourcePath = '/tmp/local-styles-element/index.less'
    result = @localStylesElement.createStyleElement(css, sourcePath)
    $result = $(result)

    expect(result).toBeDefined()
    expect(result).toBeInstanceOf(HTMLElement)
    expect($result.attr 'source-path').toEqual(sourcePath)
    expect($result.attr 'context').toEqual('atom-text-editor')
    expect($result.attr 'priority').toEqual('1')

    re = new RegExp(cssRegexSafe, "m")
    expect($result.text().match(re)).not.toBeNull()

# we need a second describe, because in this block we hook 'getActiveTextEditor'
# and we don't necessarily want that behavior in other describe blocks
describe 'LocalStylesElement2', () ->
  localStylesElement: null
  textEditor: null

  beforeEach ->
    @localStylesElement = new LocalStylesElement()

    @textEditor = atom.workspace.buildTextEditor()

    spyOn(atom.workspace, "getActiveTextEditor")
      .andReturn(@textEditor)

  xit 'setEditorBackgroundColor works', () ->
    @localStylesElement.setEditorBackgroundColor('#123456')

    expect($(@textEditor).css('background-color').toEqual('#123456'))
