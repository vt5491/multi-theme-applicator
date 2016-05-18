// Generated by CoffeeScript 1.10.0
var TextEditor, Utils;

Utils = require('../lib/utils');

TextEditor = require('atom').TextEditor;

describe('Utils', function() {
  beforeEach(function() {
    var shadowRoot, textEditor, textEditorEl, textEditorSpy;
    this.utils = new Utils();
    console.log('utils-spec: now in beforeEach');
    textEditor = atom.workspace.buildTextEditor();
    textEditorEl = textEditor.getElement();
    shadowRoot = document.createElement("shadow-root");
    textEditorEl = {
      'shadowRoot': 'shadowRoot'
    };
    textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor");
    return textEditorSpy.andReturn(textEditor);
  });
  it('doIt works', function() {
    return expect(this.utils.doIt()).toEqual(7);
  });
  return it('getActiveShadowRoot works', function() {
    console.log('ut: result=' + this.utils.getActiveShadowRoot().toString());
    return expect(this.utils.getActiveShadowRoot().toString()).toMatch(/ShadowRoot/);
  });
});

//# sourceMappingURL=utils-spec.js.map
