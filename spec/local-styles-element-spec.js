/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let jQuery;
const LocalStylesElement = require('../lib/local-styles-element');
const $ = (jQuery = require('jquery'));

describe('LocalStylesElement', function() {

  ({localStylesElement: null});

  beforeEach(function() {
    return this.localStylesElement = new LocalStylesElement();
  });

  it('doIt works', function() {
    return expect(this.localStylesElement.doIt()).toEqual(7);
  });

  return it('createStyleElement works', function() {
    const css = `\
atom-text-editor, :host {
  background-color: #e3d5c1;
  color: #000000;\
`;

    // escape special chars from css string so we can do a regex on
    const cssRegexSafe = css.replace(/\{/,'\\{');

    const sourcePath = '/tmp/local-styles-element/index.less';
    const result = this.localStylesElement.createStyleElement(css, sourcePath);
    const $result = $(result);

    expect(result).toBeDefined();
    expect(result).toBeInstanceOf(HTMLElement);
    expect($result.attr('source-path')).toEqual(sourcePath);
    expect($result.attr('context')).toEqual('atom-text-editor');
    expect($result.attr('priority')).toEqual('1');

    const re = new RegExp(cssRegexSafe, "m");
    return expect($result.text().match(re)).not.toBeNull();
  });
});

// we need a second describe, because in this block we hook 'getActiveTextEditor'
// and we don't necessarily want that behavior in other describe blocks
describe('LocalStylesElement2', function() {
  ({
    localStylesElement: null,
    textEditor: null
  });

  beforeEach(function() {
    this.localStylesElement = new LocalStylesElement();

    this.textEditor = atom.workspace.buildTextEditor();

    return spyOn(atom.workspace, "getActiveTextEditor")
      .andReturn(this.textEditor);
  });

  return xit('setEditorBackgroundColor works', function() {
    this.localStylesElement.setEditorBackgroundColor('#123456');

    return expect($(this.textEditor).css('background-color').toEqual('#123456'));
  });
});
