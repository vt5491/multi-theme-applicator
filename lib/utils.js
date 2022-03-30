/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let jQuery, Utils;
const $ = (jQuery = require('jquery'));
const Base = require('./base');
// note: this causes a circular ref. problem
// const LocalThemeSelectorView = require('./local-theme-selector-view');

module.exports =
  (Utils = class Utils {

    constructor() {}
    // adding the theme at editor level I could only get to work partial post-
    // Atom 1.13.  Leaving in as a template
    getActiveEditorElement() {
      return atom.workspace.getActiveTextEditor().getElement();
    }

    // Return the shadowRoot for the passed textEditor
    getEditorElement(editor) {
      return editor.getElement();
    }

    // Return the "all panes" container ('atom-pane-container'), which we're loosely
    // referring to as a 'window'.
    getWindowElement() {
      return document.getElementsByTagName('atom-pane-container')[0];
    }

    doIt() {
      return 7;
    }

    // This returns the active file in the editor
    // e.g "C:\vtstuff\tmp\dummy2.js"
    // normalized to unix format
    getActiveFile(ed) {
      const editor = ed || atom.workspace.getActiveTextEditor();
      let fn = null;
      if (editor && editor.getURI()) {
        fn = editor.getURI().replace(/\\/g, '/');
      }
      //vt add
      // Come here for files that haven't been saved yet and create a "dummy" fn.
      else if (editor && editor.getTitle()) {
        // fn = (editor.getTitle() + "-" + editor.id).replace(/\\/g, '/');
        fn = editor.getTitle() + "-" + editor.id;
      }
      //vt end

      return fn;
    }

    // return all the textEditors for a given parm type.  e.g if
    // params = {uri : '/myPath/abc.txt'}
    // then return all textEditors that are open on '/myPath/abc.txt'
    getTextEditors(params){
      let result;
      let editor;
      result;

      const editors = atom.workspace.getTextEditors();

      if (params.uri != null) {
        result = ((() => {
          const result1 = [];
          //vt debugger;
          for (editor of Array.from(editors)) {
            if (editor.getURI() && (editor.getURI().replace(/\\/g, '/') === params.uri)) {
              result1.push(editor);
            }
            //vt add
            // editors that have not been save yet.
            // TODO: don't need the regex replace.
            // else if ((editor.getTitle() + "-" + editor.id).replace(/\\/g, '/') === params.uri) {
            else if ((editor.getTitle() + "-" + editor.id) === params.uri) {
              result1.push(editor);
            }
            //vt end
          }
          return result1;
        })());

      } else if (params.fileExt != null) {
        // const re = new RegExp(`.${params.fileExt}$`);
        const re = new RegExp("\\." + params.fileExt + "$");

        result = ((() => {
          const result2 = [];
          for (editor of Array.from(editors)) {
            if (editor.getURI() && editor.getURI().match(re)) {
              result2.push(editor);
            }
          }
          return result2;
        })());
      }

      return result;
    }

    // reset all panes.  This is just a way to reset the panes to elminate any
    // unintended side effects from the dynamic theming
    resetPanes() {
      return Array.from(atom.workspace.getPanes()).map((pane) =>
        this.resetPane(pane));
    }

    // reset a pane just in case there have been residual effects from theming
    // operations.  For instance, if the theme is changed on a non-active editor
    // under a pane, it can sometimes "bleed" into the active editor on the pane.
    // Currently, we just reset by doing the API equivalent of switching to the next
    // tab, and then switching back.
    resetPane(pane) {
      pane.activateNextItem();
      return pane.activatePreviousItem();
    }

    // Normalize file paths to the standard format.  This means converting
    // it to unix format with '/' instead of '\'. However, we refrain from calling
    // this method "UnixfyPath" to resevere the right to use windows format
    // (or some other format) in the future, and thus calling it "normalizeFilePath"
    // is more flexible.  Note: we don't currently use much because
    // it's usually easier to say myString.replace(/blah/)
    // than @utils.normalizePath(myString)
    normalizePath(fn) {
      return fn.replace(/\\/g,'/');
    }

     // take #102030 and return "rgb(16, 32, 48)"
    hexToRgb(hex) {
       // remove leading '#', if any
       hex = hex.replace(/^#/,'');

       const bigint = parseInt(hex, 16);
       const r = (bigint >> 16) & 255;
       const g = (bigint >> 8) & 255;
       const b = bigint & 255;

       return `rgb(${r}, ${g}, ${b})`;
     }

    // get the themeName from Base.ThemeLookup given a theme path
    getThemeName(themePath){
      let themeName = '';
      for (let themeObj of Array.from(Base.ThemeLookup)) {
        if (themeObj['baseDir'] === themePath) {
          themeName = themeObj['themeName'];
          break;
        }
      }

      return themeName;
    }

    // This is a work in progress.  I actually don't need it at the moment.
    // The problem is it's very hard to distinguish between 'mta-file' and
    // 'mta-file-type'
    hasMtaFileClass(element){
      const elemClass = $(element).attr('class');
      return elemClass.match(/mta-file-/);
    }

    hasMtaFileTypeClass(element){
      return elemClass.match(/mta-fileType-/);
    }

    getFileExt(fileName) {
      let match;
      let fileExt = '';
      if (match = fileName.match(/\.(\w*)\s*$/)) {
        fileExt = match[1];
      }

      return fileExt;
    }

    //vt add
    //note: defunct: moved to ltsv.
    // editorInitSaved(key){
    //   // console.log("utils.editorInitSaved: e=" + e + ", e.path=" + e.path + ",key=" + key);
    //   return (e => {
    //     console.log("utils.editorInitSaved: e.path=" + e.path + ",key=" + key)
    //     // debugger;
    //     // console.log("utils.editorInitSave: Base.Disposables.pre.pre=" + Base.Disposables);
    //     Base.Disposables[key].dispose();
    //     console.log("utils.editorInitSave: Base.Disposables.keys.pre=" + Object.keys(Base.Disposables).length);
    //     delete Base.Disposables[key];
    //     console.log("utils.editorInitSave: Base.Disposables.keys.post=" + Object.keys(Base.Disposables).length);
    //     let activeEditor = atom.workspace.getActiveTextEditor();
    //     let currentStyle = Base.ElementLookup.get(activeEditor);
    //     Base.ElementLookup.set(activeEditor, currentStyle);
    //     // debugger;
    //     })
    // }
    //
    // editorInitSavedByKey(key){
    //   console.log("utils.editorInitSavedByKey:key=" + key);
    //   return this.editorInitSaved(key);
    // }
    //
    // addListener() {
    //   this.addEventListener('utils-abc', function (e) { console.log("hi from utils-abc") }, false);
    // }
    //vt end
  });
