Utils = require '../lib/utils'
{TextEditor} = require 'atom'

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
