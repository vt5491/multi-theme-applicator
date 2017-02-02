Utils = require '../lib/utils'

describe 'Utils', () ->
  beforeEach ->
    @utils = new Utils()

    textEditor = atom.workspace.buildTextEditor()
    textEditorEl = textEditor.getElement()

    textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor")
    textEditorSpy.andReturn(textEditor)

  it 'doIt works', () ->
    expect(@utils.doIt()).toEqual 7

describe 'Utils2', () ->
  beforeEach ->
    @utils = new Utils()

    @textEditor = atom.workspace.buildTextEditor()
    @textEditor2 = atom.workspace.buildTextEditor()
    @textEditor3 = atom.workspace.buildTextEditor()

    @editorFile = "/tmp/utils-spec-dummy.ts"
    @editorFileWinFormat= "\\tmp\\utils-spec-dummy.ts"
    @editorFile2 = "/tmp/utils-spec-dummy2.ts"

    spyOn(@textEditor, "getURI").andReturn(@editorFileWinFormat);
    # note: editor and editor2 need to use the same format to mimic a real test
    spyOn(@textEditor2, "getURI").andReturn(@editorFileWinFormat);
    spyOn(@textEditor3, "getURI").andReturn(@editorFile2);

    spyOn(atom.workspace, "getActiveTextEditor").andReturn(@textEditor)
    spyOn(atom.workspace, "getTextEditors").andReturn([@textEditor, @textEditor2, @textEditor3])

  it 'getActiveFile works', () ->
    result = @utils.getActiveFile()
    # we expect it to be normalized to unix format even its in window format
    expect(result).toMatch( new RegExp(@editorFile) )

  it 'getTextEditors works', () ->
    params = {}
    params.uri = @editorFile

    result = @utils.getTextEditors params

    expect(result.length).toEqual(2)
    expect(result[0].getURI()).toEqual(@editorFileWinFormat)
    expect(result[1].getURI()).toEqual(@editorFileWinFormat)

  it 'normalizePath works', () ->
    # windows path
    result = @utils.normalizePath('c:\\tmp\\dummy.txt')
    expect(result).toEqual('c:/tmp/dummy.txt')

    # unix path
    result = @utils.normalizePath('/tmp/dummy.txt')
    expect(result).toEqual('/tmp/dummy.txt')

  it 'hexToRgb works', () ->
    # with a leading hash mark
    result = @utils.hexToRgb("#102030")

    expect(result).toEqual("rgb(16, 32, 48)")

    # with no leading hash mark
    result = @utils.hexToRgb("102030")

    expect(result).toEqual("rgb(16, 32, 48)")

    # with lower case hex
    result = @utils.hexToRgb("#a0b0c0")

    expect(result).toEqual("rgb(160, 176, 192)")

    # with upper case hex
    result = @utils.hexToRgb("#A0B0C0")

    expect(result).toEqual("rgb(160, 176, 192)")
