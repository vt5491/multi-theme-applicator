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

    console.log 'LocalStylesElement.createStyleElement: result=' + result
    expect(result).toBeDefined()
    expect(result).toBeInstanceOf(HTMLElement)
    # expect(result.getAttribute 'source-path').toEqual(sourcePath)
    expect($result.attr 'source-path').toEqual(sourcePath)
    expect($result.attr 'context').toEqual('atom-text-editor')
    expect($result.attr 'priority').toEqual('1')
    #expect($result.text).toEqual(css)
    # pattern = css
    re = new RegExp(cssRegexSafe, "m")
    expect($result.text().match(re)).not.toBeNull()
    # expect($result.text).toMatch(re)
