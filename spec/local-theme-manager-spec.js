/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let jQuery;
const LocalThemeManager = require('../lib/local-theme-manager');
const Utils = require('../lib/utils');
const Base = require('../lib/base');
const $ = (jQuery = require('jquery'));
const fs = require('fs');
const path = require('path');

// A helper method to setup '<atom-text-editor>' test enviornment.
// We call this core environment, and then add or subtract from it in
// each describe block.
const buildEditorTestEvironment = function() {
  const textEditor = atom.workspace.buildTextEditor();

  // create some "pad" style elements that precede the the theme's style element
  // we use 'spellCheck' and 'gutter' just because these are two actual shadowRootatomStyles
  // that are attached to text-editor
  const spellCheckStyle = document.createElement('style');
  spellCheckStyle.setAttribute('source-path', '/tmp/.atom/packages/spellCheck/index.less');
  spellCheckStyle.setAttribute('priority', '0');

  const gutterStyle = document.createElement('style');
  gutterStyle.setAttribute('source-path', '/tmp/.atom/packages/gutter/gutter.less');
  gutterStyle.setAttribute('priority', '0');

  const themeStyle = document.createElement('style');
  themeStyle.setAttribute('source-path', '/tmp/.atom/packages/test-theme/index.less');
  themeStyle.setAttribute('priority', '1');

  const textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor")
  .andReturn(textEditor);

  // return to caller so they can then use in "expect" statements
  return textEditor;
};

describe('LocalThemeManager', function() {
  beforeEach(function() {
    let textEditorSpy;
    this.localThemeManager = new LocalThemeManager();
    this.utils = new Utils();

    const packageManager = atom.packages;
    const mySpy = spyOn(packageManager, "getActivePackages");
    mySpy.andReturn([ { metadata: { theme: "syntax", name: "test-syntax-theme"}}]);

    const textEditor = atom.workspace.buildTextEditor();
    atom.workspace.buildTextEditor();
    const themeStyle = document.createElement('style');
    themeStyle.setAttribute('source-path', '/tmp/.atom/packages/test-theme/index.less');

    return textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor")
      .andReturn(this.textEditor);
  });

  it('ctor works', function() {
    return expect(this.localThemeManager.utils).toBeInstanceOf(Utils);
  });

  it('doIt works', function() {
    atom.packages.getActivePackages();
    return expect(this.localThemeManager.doIt()).toEqual(7);
  });

  it('getActiveSyntaxTheme returns proper theme', function() {
    return expect(this.localThemeManager.getActiveSyntaxTheme()).toEqual("test-syntax-theme");
  });

  return xit('getThemeCss does promises correctly', function() {
    // hook fs.readFile to return a string without doing io
    const cssSnippet = `\
atom-text-editor, :host {
  background-color: #e3d5c1;
  color: #000000;\
`;
    spyOn(fs, "readFile").andReturn(cssSnippet);

    const promise = this.localThemeManager.getThemeCss('/home/vturner/.atom/packages/humane-syntax');

    expect(promise).toBeInstanceOf(Promise);

    let cssResult = null;

    return promise
      .then(
        function(result) {
          cssResult = result;
          return expect(cssResult).not.toBeNull();
        }
        ,err => console.log("promise returner err" + err));
  });
});

// here we test a more "real" style tree attached to the mock editor
describe('LocalThemeManager with complex atom-text-editor style tree', function() {
  beforeEach(function() {
    this.localThemeManager = new LocalThemeManager();
    this.utils = new Utils();

    const packageManager = atom.packages;
    const mySpy = spyOn(packageManager, "getActivePackages");
    mySpy.andReturn([ { metadata: { theme: "syntax", name: "test-syntax-theme"}}]);

    return this.textEditor = buildEditorTestEvironment();
  });

  it('addStyleElementToHead works', function() {
    Date.now.andReturn(1234512345123);
    const styleElem = document.createElement('style');

    // editor scope
    let styleClass = this.localThemeManager.addStyleElementToHead(styleElem, 'editor', "mystyle");
    const firstStyleClass = styleClass;

    // verify it's now there
    let elem = $('head').find(`atom-styles .${styleClass}`)[0];
    expect(elem).toBeTruthy();
    expect(elem.getAttribute('class').match(/editor/)).toBeTruthy();

    // pane scope
    styleClass = this.localThemeManager.addStyleElementToHead(styleElem, 'pane', "mystyle");

    // verify it's now there
    elem = $('head').find(`atom-styles .${styleClass}`)[0];
    expect(elem).toBeTruthy();

    // Verify it re-uses existing styleClass from head if a previous one is found
    // oldStyleClass = styleClass
    const oldHeadCnt = $('head atom-styles style').length;
    // debugger
    styleClass = this.localThemeManager.addStyleElementToHead(styleElem, 'editor', "mystyle");
    expect(styleClass).toEqual(firstStyleClass);
    return expect($('head atom-styles style').length).toEqual(oldHeadCnt);
  });

  // it 'addStyleElementToHead re-uses existing styleClass from head if a previous one is found', () ->

  // this is too hard to unit-test.  The code is expecting the bg color to be
  // at this location:
  //bgColor = node3[0].sheet.rules[0].style.backgroundColor
  // and I don't want to set that up
  return xit('syncEditorBackgroundColor works', function() {
    return console.log('syncEditorBackgroundColor: @textEditor=' + this.textEditor);
  });
});

describe("LocalThemeManager getSyntaxThemeLookup tests", function() {
   const packageMetadataMock = [];
   packageMetadataMock.push({name: 'atom-beautify'});
   packageMetadataMock.push({name: 'choco', theme: 'syntax'});
   packageMetadataMock.push({name: 'humane-syntax', theme: 'syntax'});

   const packagePathsMock = [];
   packagePathsMock.push("/home/user/.atom/packages/atom-beautify");
   packagePathsMock.push("/home/user/.atom/packages/choco");
   packagePathsMock.push("/home/user/.atom/packages/humane-syntax");

   beforeEach(function() {
     this.localThemeManager = new LocalThemeManager();
     this.textEditor = atom.workspace.buildTextEditor();

     spyOn(atom.packages, "getAvailablePackageMetadata")
       .andReturn(packageMetadataMock);
     return spyOn(atom.packages, "getAvailablePackagePaths")
       .andReturn(packagePathsMock);
   });

   it('getSyntaxThemeLookup works', function() {
     const result = this.localThemeManager.getSyntaxThemeLookup();

     expect(result).toBeInstanceOf(Array);
     expect(result.length).toEqual(2);
     expect(result[0].themeName).toEqual("choco");
     return expect(result[0].baseDir).toEqual("/home/user/.atom/packages/choco");
   });

   it('narrowStyleScope works with two line css selector', function() {
     const styleKey = 'abc';

     // two-line selector with ':host' keyword
     // atom-text-editor flavor
     const css = `\
atom-text-editor,
:host {
  background-color: #212020;
  color: #fff0ed;
}
.syntax--comment {
  color: #7C7C7C;
}\
`;

     const expectedCssFrag_1 = `atom-text-editor.${styleKey}.editor`;
     const re_1 = new RegExp(expectedCssFrag_1, 'gm');

     const expectedCssFrag_2 = `.${styleKey}.editor .syntax--comment`;
     const re_2 = new RegExp(expectedCssFrag_2, 'gm');

     let result = this.localThemeManager.narrowStyleScope(css, styleKey, "file");

     expect(result.match(re_1)).toBeTruthy();
     expect(result.match(re_2)).toBeTruthy();

     // pane level test
     const expectedCssFrag = `.${styleKey} atom-text-editor`;

     result = this.localThemeManager.narrowStyleScope(css, styleKey, "pane");

     const re = new RegExp(expectedCssFrag, 'gm');
     return expect(result.match(re)).toBeTruthy();
   });

   it('narrowStyleScope works with one line css selector', function() {
     const styleKey = 'abc';

     // one line selector
     const css = `\
atom-text-editor .gutter {
  color: #959595;
}\
`;

     const expectedCss = `\
atom-text-editor.${styleKey}.editor .gutter {
  color: #959595;
}\
`;

     const result = this.localThemeManager.narrowStyleScope(css, styleKey, 'editor');

     return expect(result).toEqual(expectedCss);
   });

   it('narrowStyleScope works with "syntax--" keyword', function() {
     const styleKey = 'abc';

     // one line selector
     const css = `\
.syntax--comment {
  color: #ff79c6;
}\
`;

     const expectedCss = `\
.${styleKey} .syntax--comment {
  color: #ff79c6;
}\
`;

     const result = this.localThemeManager.narrowStyleScope(css, styleKey, 'pane');

     return expect(result).toEqual(expectedCss);
   });

   it('removeStyleElementFromHead works', function() {
     const styleClass = 'mta-editor-style-1234567890123';

     $('head atom-styles .' + styleClass).remove();

     const headStyleElement = document.createElement('style');

     headStyleElement.setAttribute('context', 'atom-text-editor' );
     headStyleElement.setAttribute('class', styleClass );

     $.find('head atom-styles')[0].appendChild(headStyleElement);

     // verify it's there before we delete
     expect($.find(`head atom-styles style.${styleClass}`).length).toEqual(1);

     // and now verify it was deleted
     this.localThemeManager.removeStyleElementFromHead(styleClass);
     expect($.find(`head atom-styles style.${styleClass}`).length).toEqual(0);

     // idempotency test: verify there are no problems when remove is called
     // multiple times
     return expect($.find(`head atom-styles style.${styleClass}`).length).toEqual(0);
   });

   it('getCssBgColor returns the proper background-color', function() {
    let css = `\
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
}\
`;
    let result = this.localThemeManager.getCssBgColor(css);
    expect(result).toEqual("#282a36");

    // make sure it handles a non-matching case gracefully
    css = "nada match";
    result = this.localThemeManager.getCssBgColor(css);
    expect(result).toBeNull();

    // upper case hex test
    css = `\
atom-text-editor,
:host {
  background-color: #5A5475;
  color: #F8F8F2;
}
atom-text-editor .gutter,
:host .gutter {
  background-color: #5A5475;
  color: #F8F8F2;
}\
`;

    result = this.localThemeManager.getCssBgColor(css);
    return expect(result).toEqual("#5A5475");
   });

   return it('normalizeSyntaxScope properly add .syntax-- to non atom 1.13 compatible themes', function() {

     const css = `\
atom-text-editor,
:host {
  background-color: #212020;
  color: #fff0ed;
}
.comment {
  color: #7C7C7C;
}\
`;

    //  debugger
     const result = this.localThemeManager.normalizeSyntaxScope(css);

     // lines with 'atom' should be unaffected
     let expectedCssFrag = "^atom-text-editor,";
     let re = new RegExp(expectedCssFrag, 'gm');

     expect(result.match(re)).toBeTruthy();

     // non-atom elements should have 'syntax--' format
     expectedCssFrag = "^.syntax--comment";
     re = new RegExp(expectedCssFrag, 'gm');

     return expect(result.match(re)).toBeTruthy();
   });
});

describe("LocalThemeManager scoped theme removal tests", function() {

  beforeEach(function() {
    this.localThemeManager = new LocalThemeManager();

    // setup textEditors
    this.textEditor_1 = atom.workspace.buildTextEditor();
    // atom.workspace.buildTextEditor()

    this.textEditor_2 = atom.workspace.buildTextEditor();

    const textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor")
      .andReturn(this.textEditor_1);

    // mock up an 'atom-text-editor' element
    this.styleClass_editor = 'mta-editor-style-1234567890123';
    this.styleClass_file = 'mta-file-style-1234567890123';

    const $editorElem_1 = $('<atom-text-editor></atom-text-editor');
    $editorElem_1.attr('class', this.styleClass_editor);
    $editorElem_1.addClass(this.styleClass_file);
    const editorElem_1 = $editorElem_1[0];
    spyOn(this.textEditor_1, "getElement").andReturn(editorElem_1);
    spyOn(this.textEditor_1, "getURI").andReturn("/mydir/abc.txt");
    spyOn(this.textEditor_1, "getPath").andReturn("/mydir/abc.txt");

    const $editorElem_2 = $('<atom-text-editor></atom-text-editor');
    $editorElem_2.attr('class', this.styleClass_file);
    const editorElem_2 = $editorElem_2[0];
    spyOn(this.textEditor_2, "getElement").andReturn(editorElem_2);
    spyOn(this.textEditor_2, "getURI").andReturn("/mydir/abc.txt");
    spyOn(this.textEditor_2, "getPath").andReturn("/mydir/abc.txt");
    // setup Base.ElementLookup
    Base.ElementLookup.set(this.textEditor_1, {"editor" : {'styleClass' : this.styleClass_editor} });
    Base.ElementLookup.get(this.textEditor_1)['file'] = {'styleClass' : this.styleClass_file};

    Base.ElementLookup.set(this.textEditor_2, {"file" : {'styleClass' : this.styleClass_file} });

    // Setup head style element
    const headStyleElement_editor = document.createElement('style');
    const headStyleElement_file = document.createElement('style');

    headStyleElement_editor.setAttribute('context', 'atom-text-editor' );
    headStyleElement_editor.setAttribute('class', this.styleClass_editor );

    headStyleElement_file.setAttribute('class', this.styleClass_file );

    // We have to manually remove from head since beforeEach doesn't automatically
    // clean up the DOM.
    $('head atom-styles .' + this.styleClass_editor).remove();
    $('head atom-styles .' + this.styleClass_file).remove();

    $('head atom-styles ').append(headStyleElement_editor);
    $('head atom-styles').append(headStyleElement_file);

    const editors = [];
    editors.push(this.textEditor_1);
    editors.push(this.textEditor_2);

    return spyOn(atom.workspace, 'getTextEditors').andReturn(editors);
  });

  it('removeScopedTheme removes the theme properly from an editor', function() {
    this.localThemeManager.removeScopedTheme('editor');

    // verify head element removed
    expect($('head').find(`.${this.styleClass_editor}`).length ).toEqual(0);
    expect($('head').find(`.${this.styleClass_file}`).length > 0 ).toBeTruthy();

    //verify element class is removed
    return expect($(`atom-text-editor.${this.styleClass_editor}`).length).toEqual(0);
  });

  return it('removeScopedTheme removes the theme properly from a file scope', function() {
    this.localThemeManager.removeScopedTheme('file');

    // verify head element removed
    expect($('head').find(`.${this.styleClass_editor}`).length ).toEqual(1);
    expect($('head').find(`.${this.styleClass_file}`).length).toEqual(0);

    //verify element class is removed
    return expect($(`atom-text-editor.${this.styleClass_file}`).length).toEqual(0);
  });
});
