Utils = require '../lib/utils'
#vt{TextEditor} = require 'atom'

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

  #vt add
    #expect(@utils.getActiveFilePath().toString()) .toMatch(/ShadowRoot/)
    # console.log('textEditor=' + @textEditor2)
    # console.log('textEditor=' + @textEditor2.getPath())
  #vt end

#vt add
describe 'Utils2', () ->
  beforeEach ->
    @utils = new Utils()
    #vt add
    #spyOn(textEditor, "getPath").and.returnValue("/tmp/utils-spec-dummy.ts");
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
    #vt end

  it 'getActiveURI works', () ->
    console.log "hello4"
    # console.log("utils-spec.coffee: getPath=#{@textEditor.getPath()}" )
    console.log "activeFilePath= #{@utils.getActiveURI()}"
    expect(@utils.getActiveURI()).toMatch(///#{@editorFile}///)

  it 'getTextEditors works', () ->
    params = {}
    params.uri = @editorFile

    result = @utils.getTextEditors params
    console.log "result=#{result}"
    console.log "final follows"
    console.log  editor for editor in result
    # for( i = 0; i < )
    expect(result.length).toEqual(2)
    expect(result[0].getURI()).toEqual(@editorFile)
    expect(result[1].getURI()).toEqual(@editorFile)
#vt end
