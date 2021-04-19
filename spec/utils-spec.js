/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let jQuery;
const Utils = require('../lib/utils');
const Base = require('../lib/base');
const $ = (jQuery = require('jquery'));

describe('Utils', function() {
  beforeEach(function() {
    this.utils = new Utils();

    const textEditor = atom.workspace.buildTextEditor();
    const textEditorEl = textEditor.getElement();

    const textEditorSpy = spyOn(atom.workspace, "getActiveTextEditor");
    return textEditorSpy.andReturn(textEditor);
  });

  return it('doIt works', function() {
    return expect(this.utils.doIt()).toEqual(7);
  });
});

describe('Utils2', function() {
  beforeEach(function() {
    this.utils = new Utils();

    this.textEditor = atom.workspace.buildTextEditor();
    this.textEditor2 = atom.workspace.buildTextEditor();
    this.textEditor3 = atom.workspace.buildTextEditor();
    this.textEditor4 = atom.workspace.buildTextEditor();

    // add a file type class
    $(this.textEditor.getElement()).addClass('mta-file-type-atom-light-syntax-style-1486192129232');

    // add a file class
    $(this.textEditor.getElement()).addClass('mta-file-dracula-theme-style-1486192106901');

    // add an editor class
    $(this.textEditor.getElement()).addClass('mta-editor-fairyfloss-style-1486192106901');

    this.editorFile = "/tmp/utils-spec-dummy.ts";
    this.editorFileWinFormat= "\\tmp\\utils-spec-dummy.ts";
    this.editorFile2 = "/tmp/utils-spec-dummy2.js";
    this.editorFile3 = "/tmp/utils-spec-dummy3.cljs";

    spyOn(this.textEditor, "getURI").andReturn(this.editorFileWinFormat);
    // note: editor and editor2 need to use the same format to mimic a real test
    spyOn(this.textEditor2, "getURI").andReturn(this.editorFileWinFormat);
    spyOn(this.textEditor3, "getURI").andReturn(this.editorFile2);
    spyOn(this.textEditor4, "getURI").andReturn(this.editorFile3);

    spyOn(atom.workspace, "getActiveTextEditor").andReturn(this.textEditor);
    return spyOn(atom.workspace, "getTextEditors").andReturn([this.textEditor, this.textEditor2, this.textEditor3, this.textEditor4]);
  });

  it('getActiveFile works', function() {
    const result = this.utils.getActiveFile();
    // we expect it to be normalized to unix format even its in window format
    return expect(result).toMatch( new RegExp(this.editorFile) );
  });

  it('getTextEditors works by file', function() {
    const params = {};
    params.uri = this.editorFile;

    const result = this.utils.getTextEditors(params);

    expect(result.length).toEqual(2);
    expect(result[0].getURI()).toEqual(this.editorFileWinFormat);
    return expect(result[1].getURI()).toEqual(this.editorFileWinFormat);
  });

  it('getTextEditors works by file type', function() {
    const params = {};
    params.fileExt = "js";

    const result = this.utils.getTextEditors(params);

    expect(result.length).toEqual(1);
    return expect(result[0].getURI().match(/utils-spec-dummy2\.js/)).toBeTruthy();
  });

  it('normalizePath works', function() {
    // windows path
    let result = this.utils.normalizePath('c:\\tmp\\dummy.txt');
    expect(result).toEqual('c:/tmp/dummy.txt');

    // unix path
    result = this.utils.normalizePath('/tmp/dummy.txt');
    return expect(result).toEqual('/tmp/dummy.txt');
  });

  it('hexToRgb works', function() {
    // with a leading hash mark
    let result = this.utils.hexToRgb("#102030");

    expect(result).toEqual("rgb(16, 32, 48)");

    // with no leading hash mark
    result = this.utils.hexToRgb("102030");

    expect(result).toEqual("rgb(16, 32, 48)");

    // with lower case hex
    result = this.utils.hexToRgb("#a0b0c0");

    expect(result).toEqual("rgb(160, 176, 192)");

    // with upper case hex
    result = this.utils.hexToRgb("#A0B0C0");

    return expect(result).toEqual("rgb(160, 176, 192)");
  });

  // I just cannot get Base properly setup to test this
  xit('getThemeName works', function() {
    // @utils.Base.ThemeLookup.push {baseDir: '/tmp/abc.theme', themeName: 'abc'}
    // @utils.Base.ThemeLookup.push {baseDir: '/tmp/def.theme', themeName: 'def'}
    // Base.ThemeLookup.push {baseDir: '/tmp/abc.theme', themeName: 'abc'}
    // Base.ThemeLookup.push {baseDir: '/tmp/def.theme', themeName: 'def'}
    // Base::ThemeLookup.push {baseDir: '/tmp/abc.theme', themeName: 'abc'}
    // Base::ThemeLookup.push {baseDir: '/tmp/def.theme', themeName: 'def'}
    // themes = []
    // themes.push {baseDir: '/tmp/abc.theme', themeName: 'abc'}
    // themes.push {baseDir: '/tmp/def.theme', themeName: 'def'}
    // spyOn(@utils, "Base.ThemeLookup").andReturn(themes)
    // Base.ThemeLookup = themes
    // console.log "@utils.Base=#{@utils.Base}"
    // utilsClosure = function () {
    //   Base = Base;
    //   getThemeName = @utils.getThemeName
    // }
    // utilsClosure: (arg) ->
    const utilsClosure = arg => {
      // Base = Base;
      console.log(`now in utilsClosure: arg=${arg}`);
      // require '../base'
      Base.ThemeLookup.push({baseDir: '/tmp/abc.theme', themeName: 'abc'});
      Base.ThemeLookup.push({baseDir: '/tmp/def.theme', themeName: 'def'});
      // @utils.getThemeName arg;
      const utils = new Utils();
      // debugger
      // @utils.getThemeName arg
      return utils.getThemeName(arg);
    };

    // debugger
    const result = this.utils.getThemeName('/tmp/abc.theme');
    // result = utilsClosure( '/tmp/abc.theme')
    return console.log(`result=${result}`);
  });
    // expect(@utils.getThemeName '/tmp/abc.theme').toEqual('abc')
    // expect(@utils.getThemeName '/tmp/def.theme').toEqual('def')
    // expect(@utils.getThemeName '/tmp/ghi.theme').toBeFalsy()

  it('hasMtaFileClass works', function() {
    expect(this.utils.hasMtaFileClass(this.textEditor.getElement())).toBeTruthy();
    return expect(this.utils.hasMtaFileClass(this.textEditor2.getElement())).toBeFalsy();
  });

  it('hasMtaFileTypeClass works', function() {
    expect(this.utils.hasMtaFileClass(this.textEditor.getElement())).toBeTruthy();
    return expect(this.utils.hasMtaFileClass(this.textEditor2.getElement())).toBeFalsy();
  });

  return it('getFileExt works', function() {
    expect(this.utils.getFileExt("abc.txt")).toEqual("txt");
    expect(this.utils.getFileExt("abc.txt ")).toEqual("txt");
    expect(this.utils.getFileExt("abc.def.txt")).toEqual("txt");
    return expect(this.utils.getFileExt("abc")).toEqual("");
  });
});
