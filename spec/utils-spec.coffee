Utils = require '../lib/utils'
{TextEditor} = require 'atom'

describe 'Utils', () ->
  beforeEach ->
    @utils = new Utils()

    console.log('utils-spec: now in beforeEach')
    textEditor = atom.workspace.buildTextEditor()
    #textEditorEl = document.createElement('atom-text-editor')
    textEditorEl = textEditor.getElement()
    # shadowRoot = document.createTextNode("This is a new paragraph.");
    shadowRoot = document.createElement("shadow-root")
    # textEditorEl.appendChild(shadowRoot)
    # textEditorEl[0] = {'shadowRoot': 'shadow-root'}
    textEditorEl = {'shadowRoot': 'shadowRoot'}


    #dummyElement = document.createElement('div');
    #document.getElementById = jasmine.createSpy('HTML Element').andReturn(dummyElement);
    textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor")
    textEditorSpy.andReturn(textEditor)

  it 'doIt works', () ->
    expect(@utils.doIt()).toEqual 7

  it 'getActiveShadowRoot works', () ->
    console.log('ut: result=' + @utils.getActiveShadowRoot().toString())
    expect(@utils.getActiveShadowRoot().toString()).toMatch(/ShadowRoot/)
