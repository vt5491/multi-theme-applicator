Utils = require '../lib/utils'

describe 'Utils', () ->
  beforeEach ->
    @utils = new Utils()

    textEditor = atom.workspace.buildTextEditor()
    textEditorEl = textEditor.getElement()
    shadowRoot = document.createElement("shadow-root")
    textEditorEl = {'shadowRoot': 'shadowRoot'}

    textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor")
    textEditorSpy.andReturn(textEditor)

  it 'doIt works', () ->
    expect(@utils.doIt()).toEqual 7

  it 'getActiveShadowRoot works', () ->
    expect(@utils.getActiveShadowRoot().toString()).toMatch(/ShadowRoot/)

describe 'Utils2', () ->
  beforeEach ->
    @utils = new Utils()

    @textEditor = atom.workspace.buildTextEditor()
    @textEditor2 = atom.workspace.buildTextEditor()
    @textEditor3 = atom.workspace.buildTextEditor()

    @editorFile = "/tmp/utils-spec-dummy.ts"
    @editorFile2 = "/tmp/utils-spec-dummy2.ts"

    spyOn(@textEditor, "getURI").andReturn(@editorFile);
    spyOn(@textEditor2, "getURI").andReturn(@editorFile);
    spyOn(@textEditor3, "getURI").andReturn(@editorFile2);

    spyOn(atom.workspace, "getActiveTextEditor").andReturn(@textEditor)
    spyOn(atom.workspace, "getTextEditors").andReturn([@textEditor, @textEditor2, @textEditor3])

  it 'getActiveURI works', () ->
    expect(@utils.getActiveURI()).toMatch(///#{@editorFile}///)

  it 'getTextEditors works', () ->
    params = {}
    params.uri = @editorFile

    result = @utils.getTextEditors params

    expect(result.length).toEqual(2)
    expect(result[0].getURI()).toEqual(@editorFile)
    expect(result[1].getURI()).toEqual(@editorFile)
