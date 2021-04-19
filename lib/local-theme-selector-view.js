/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let jQuery, LocalThemeSelectorView;
const $ = (jQuery = require('jquery'));
const {CompositeDisposable} = require('atom');
const Utils = require('./utils');
const LocalThemeManager = require('./local-theme-manager');
const LocalStylesElement  = require('./local-styles-element');
const Base = require('./base');
const fs = require('fs-plus');

// This is basically the main application class.  LocalThemeManager "should"
// probably be the main class, but LocalThemeSelectorView has kind of taken over
// as the main focal point, with LocalThemeManager being more of a support
// module.  This module should probably be renamed to drop the "view" from its
// name, as this denotes it's only for the front-end view
//
// The point is, feel free to add non-view related functionality to this class.

// Data Structure documentation:
// @fileLookup
// the key is the name of the file in the editor.  The value is fully qualified path
// to the style that is applied to it.
// Example:
// C:/vtstuff/github/multi-theme-applicator/lib/local-styles-element.coffee
// :
// "C:/Users/vturner/AppData/Local/atom/app-1.13.0/resources/app.asar/node_modules/atom-light-syntax"
// C:/vtstuff/github/multi-theme-applicator/lib/multi-theme-applicator.coffee
// :
// "C:/Users/vturner/.atom/packages/fairyfloss"

// @themeLookup
// Is basically just a directory of themes and where the theme file is located.
// It's an array of objects.  Each object has two keys: 'themeName' and 'baseDir'
// Object {themeName: "choco", baseDir: "C:/Users/vturner/.atom/packages/choco"}
//
// baseDir:"C:/Users/vturner/.atom/packages/choco"
// themeName:"choco"
//
// i.e. It is not used for keeping track of what theme is applied to what file etc.

// @elementLookup
// defined in Base
// Used to keep track of elements that we have styled.  It's a WeakMap.  The key
// is the dom element (not jquery Element). We associate a js object with this key.
// The keys in the js object are:
// type, theme, class
//
//# jqPath: a path that you can pass to jquery such that it will uniquely identify the element.
//#  note: use utils->getEditorPath, getPanePath, getWindowPath to get a normalized
//#        and standard jqPath
// type: The style scope: {windows, pane, file, editor}
// theme: the theme applied e.g "fairyfloss"
// styleClass: the style tag that has been added to the element's class e.g. 'mta-editor-style-1484974763214'

// Base.FileTypeLookup:
// key: the file extension e.g. 'ts', 'js'
// value: the fully qualified css path to the theme for this file type

module.exports =
  (LocalThemeSelectorView = (function() {
    LocalThemeSelectorView = class LocalThemeSelectorView {
      static initClass() {
        this.prototype.selectorView = null;

        // keep track of the local theme applied by file.
        this.prototype.fileLookup = {};
        // keep track of the state of each element we apply a local theme to.
        this.prototype.elementLookup = WeakMap;
      }

      constructor(multiThemeApplicator, prevSessionFileLookupState, prevSessionFileTypeLookupState, prevThemeLookupState) {
        // console.log "LocalThemeSelectorView.ctor: entered"
        this.multiThemeApplicator =  multiThemeApplicator;
        // restore the prior fileLookupState, if any
        this.fileLookup = prevSessionFileLookupState || {};
        this.elementLookup = Base.ElementLookup;
        Base.FileTypeLookup = prevSessionFileTypeLookupState || {};
        Base.ThemeLookup = prevThemeLookupState || [];

        // create all the supporting services we may need to call
        this.localThemeManager = new LocalThemeManager();
        this.localStylesElement = new LocalStylesElement();
        this.utils = new Utils();

        this.reapplyThemes();
        this.initThemeSelectorForm();
        // setup the pane listener, so we can automatically apply the local theme to any
        // new editors that show up.
        this.localThemeManager.initPaneEventHandler(this);

        // setup pane close events so we can delete any styling context
        this.localThemeManager.initOnDidDestroyPaneHandler();
        // setup pane item close events (e.g editor closings) so we can delete any styling context
        this.localThemeManager.initOnDidDestroyPaneItem();
        // seed the initial active element.  This value will change as the user
        // selects via key bindings or mouse the selected theme in the dropdown.
        this.themeLookupActiveIndex = 0;

        this.subscriptions = new CompositeDisposable;

        // Register command that toggles this view
        this.subscriptions.add(atom.commands.add('atom-workspace', {
          'multi-theme-applicator:applyLocalTheme':  () => this.applyLocalTheme(),
          'local-theme-selector-view:focusModalPanel':  () => this.focusModalPanel()
        }
        )
        );

        this.subscriptions.add(atom.commands.add('.local-theme-selector-view', {
          'local-theme-selector-view:applyLocalTheme':  () => this.applyLocalTheme(),
          'local-theme-selector-view:selectPrevTheme':  () => this.selectPrevTheme(),
          'local-theme-selector-view:selectNextTheme':  () => this.selectNextTheme(),
          'local-theme-selector-view:expandThemeDropdown':  () => this.expandThemeDropdown(),
          'local-theme-selector-view:multiThemeApplicatorToggle': () => this.multiThemeApplicator.toggle()
        }
        )
        );
      }

      // end ctor

      initThemeSelectorForm() {
        // create container element for the form
        this.selectorView = document.createElement('div');
        this.selectorView.classList.add('multi-theme-applicator','local-theme-selector-view');
        $('.local-theme-selector-view').attr({ tabindex: '0'});

        const $form = $('<form/>')
          .attr({ id: 'input-form', class: 'apply-theme-form'})
          .submit(() => this.applyLocalTheme());

        $form.appendTo(this.selectorView);

        const $themeDiv = $('<div class="theme"></div>');
        $form.append($themeDiv);

        $('<label>').text('Syntax Theme:').appendTo($themeDiv);

        this.dropDownBorderWidthDefault;
        const $themeDropdown = $('<select id="themeDropdown" name="selectTheme"></select>');
        $themeDropdown.focus(() => {
          this.dropDownBorderWidthDefault = $('#themeDropdown').css('borderWidth');
          const newBorderWidth = parseInt(this.dropDownBorderWidthDefault) * 2.0;
          return $('#themeDropdown').css('borderWidth', newBorderWidth.toString());
        });

        $themeDropdown.blur(() => {
          return $('#themeDropdown').css('borderWidth', this.dropDownBorderWidthDefault);
        });

        this.refreshThemeInfo($themeDropdown);

        // register a listener for onChange, so we can clear any error messages from
        // the last selection
        $themeDropdown.change(() => {
          $('#input-form span.error').text('');
          return $('#input-form span.error').css("visibility", "hidden");
      });

        $themeDropdown.appendTo($themeDiv);

        const closeModalDialogButton = $("<span>");
        closeModalDialogButton.attr({id: 'close-modal-dialog'});
        closeModalDialogButton.text('x');
        closeModalDialogButton.appendTo($themeDiv);
        closeModalDialogButton.click(
          this.multiThemeApplicator.toggle.bind(this.multiThemeApplicator)
        );

        const $scopeDiv = $('<div class="scope"></div>').appendTo($form);
        $('<label>').text('Scope:').appendTo($scopeDiv);
        $('<input type="radio" name="scope" value="window">Window</input>').appendTo($scopeDiv);
        $('<input type="radio" name="scope" value="pane">Pane</input>').appendTo($scopeDiv);
        $('<input type="radio" name="scope" value="fileType" checked>FileType</input>').appendTo($scopeDiv);
        $('<input type="radio" name="scope" value="file" checked>File</input>').appendTo($scopeDiv);
        $('<input type="radio" name="scope" value="editor">Editor</input>').appendTo($scopeDiv);

        const $submitDiv = $('<div class="submit"></div>');
        $form.append($submitDiv);

        const $submitBtn = $('<button type="submit" form="input-form" value="Apply Scoped Theme">Apply Scoped Theme</button>');
        $submitBtn.appendTo($submitDiv);

        const $removeScopedThemeBtn = $('<button type="button"></button>');
        $removeScopedThemeBtn.text('Remove Scoped Theme');
        $removeScopedThemeBtn.attr('id', 'remove-scoped-theme');
        $removeScopedThemeBtn.appendTo($submitDiv);
        return $removeScopedThemeBtn.click(() => {
          const scope = $('input[name=scope]:checked').val();
          this.localThemeManager.removeScopedTheme(scope);
          // return false so the main submit action is not applied
          return false;
        });
      }

      reapplyThemes() {
        for (let editor of Array.from(atom.workspace.getTextEditors())) {
          const editorFile = this.utils.getActiveFile(editor);
          // skip to next editor if no active file
          if (!editorFile) { break; }
          const fileExt = this.utils.getFileExt(editorFile);

          if (Base.FileTypeLookup && (Object.keys(Base.FileTypeLookup).length > -1)) {
            if (Base.FileTypeLookup[fileExt]) {
              this.applyLocalTheme(editorFile, Base.FileTypeLookup[fileExt], 'file', editor);
            }
          }

          if (this.fileLookup && (Object.keys(this.fileLookup).length > -1)) {
            if (this.fileLookup[editorFile]) {
              this.applyLocalTheme(editorFile, this.fileLookup[editorFile], 'file', editor);
            }
          }
        }
        return true;
      }

      refreshThemeInfo($themeDropdown) {
        const $dropDown = $themeDropdown != null ? $themeDropdown : $('#themeDropdown');
        Base.ThemeLookup = this.localThemeManager.getSyntaxThemeLookup();
        const themeDropdownHtml = this.localThemeManager.getThemeDropdownHtml(Base.ThemeLookup);
        return $dropDown.html(themeDropdownHtml);
      }

      selectNextTheme() {
        this.themeLookupActiveIndex++;
        this.themeLookupActiveIndex %= Base.ThemeLookup.length;

        return $("#themeDropdown")
          .val(Base.ThemeLookup[this.themeLookupActiveIndex].baseDir).attr('name');
      }

      selectPrevTheme() {
        this.themeLookupActiveIndex--;
        if (this.themeLookupActiveIndex < 0) {
          this.themeLookupActiveIndex = Base.ThemeLookup.length - 1;
        }

        return $("#themeDropdown")
          .val(Base.ThemeLookup[this.themeLookupActiveIndex].baseDir).attr('name');
      }

      focusModalPanel() {
        return $('#themeDropdown').focus();
      }

      // simulate a mouse click on the theme dropdown, so the user can see
      // a larger selection.
      expandThemeDropdown() {
        const element = document.getElementById('themeDropdown');
        let expandLen = element.options.length;
        const currentLen = element.getAttribute('size');
        // toggle if already expand
        // note '+currentlen' converts a string to an int
        if (+currentLen === expandLen) {
          expandLen = 1;
        }
        return element.setAttribute('size', expandLen);
      }

      // Come here on submit.  Apply a theme at the window level, not the individual editor
      // level.
      // This is the key method of the whole package.  This basically drives all the
      // other supporting modules.
      applyLocalTheme(fn, themePath, scope, ed) {
        const themeScope = scope || $("input[type='radio'][name='scope']:checked").val();

        if (!themeScope) {
          console.log("LocalThemeSelectorView.applyLocalTheme: skipping because no themeScope");
          return;
        }

        const baseCssPath = themePath || $( "#themeDropdown" ).val();
        const themeName = this.utils.getThemeName(baseCssPath);
        const sourcePath = baseCssPath + '/index.less';

        const targetFile = fn || this.utils.getActiveFile();
        if (!targetFile) {
          const noFilesMsg = `No active file found.
MTA scoped themes are applied to the currently opened file.
Please open a file and then apply a local theme.`;
          atom.workspace.notificationManager.addError(noFilesMsg);
          return;
        }

        // get the "ts" from "myfile.ts", for example
        const fileExt = this.utils.getFileExt(targetFile);

        // an fn arg means this is an application to a file that falls under an
        // existing rule.  Therefore, we don't need to save it's theme state, as it
        // should already be covered by another file or fileExt.
        if (!fn) {
          if ((themeScope === "file") || (themeScope === "editor")) {
            // Remember what theme is applied to what file.
            this.fileLookup[targetFile] = baseCssPath;

          } else if (themeScope === "fileType") {
            Base.FileTypeLookup[fileExt] = baseCssPath;
          }
        }

        const promise = this.localThemeManager.getThemeCss(baseCssPath);

        const styleElement = null;

        return promise
          .then(
            result => {
              let elemState, prevStyleClass;
              let css = result;

              // attempt to normalize normalize pre atom 1.13 themes
              if (!css.match(/\.syntax--comment/gm)) {
                css = this.localThemeManager.normalizeSyntaxScope(css);
              }

              const newStyleElement = this.localStylesElement.createStyleElement(css, sourcePath);

              switch (themeScope) {
                case "fileType": case "file": case "editor":
                  var styleClass = this.localThemeManager.addStyleElementToHead(newStyleElement, themeScope, themeName);

                  var narrowedCss = this.localThemeManager.narrowStyleScope(css, styleClass, themeScope);
                  $(newStyleElement).text(narrowedCss);

                  var params = {};

                  var editors = [];
                  if (themeScope === "file") {
                    params.uri = fn || this.utils.getActiveFile();
                    // get all the textEditors open for this file
                    editors = this.utils.getTextEditors(params);
                  } else if ((themeScope === "fileType") && !fn) {
                    params.fileExt = fileExt;
                    // get all the textEditors open for this file ext
                    editors = this.utils.getTextEditors(params);
                    console.log("vt.ltsv: fileExt=" + fileExt + ",editors=" + editors);
                    console.log(editors);
                    // debugger;
                  } else {
                    editors.push(ed || atom.workspace.getActiveTextEditor());
                  }

                  for (let editor of Array.from(editors)) {
                    // We have to get a new styleElement each time i.e. we need to clone
                    // it.  If we create just one styleElement outside of this loop, it will simply get reassigned
                    // to the last editor we attach it too, and it won't be assigned to any of
                    // the previous editors
                    const editorElem = editor.getElement();

                    // if the editor element already has the new styleClass applied, skip it.
                    // We only want to update new elements.  If we update already updated elements, then
                    // the new class can override lower styles that should be taking effect.
                    if ($(editorElem).attr('class').match( new RegExp(styleClass))) { continue; }
                    if (!this.elementLookup.get(editor)) {
                      // create a two-tier lookup element->'file'
                      this.elementLookup.set(editor, {[themeScope] : {} });
                    }

                    if (this.elementLookup.get(editor) && this.elementLookup.get(editor)[themeScope]) {
                      prevStyleClass = this.elementLookup.get(editor)[themeScope]['styleClass'];
                    }

                    // since multiple editors can be associated with one head style

                    // we will typically be deleting the head style multiple times, but the
                    // operation is idempotent, so this is safe.  By the time we determine
                    // that we don't need to delete it, we could have already gone ahead and
                    // just deleted it.  So it's easier and simpler to just delete it multiple times.
                    if (prevStyleClass) {
                      this.localThemeManager.removeStyleElementFromHead(prevStyleClass);
                    }

                    $(editorElem).removeClass(prevStyleClass);
                    $(editorElem).addClass(styleClass);

                    // save the current element state in @elementLookup
                    elemState = this.elementLookup.get(editor);

                    if (!elemState[themeScope]) {
                      elemState[themeScope] = {};
                    }

                    elemState[themeScope]['type'] = themeScope;
                    elemState[themeScope]['styleClass'] = styleClass;
                  }
                  break;

                case "pane":
                  styleClass = this.localThemeManager.addStyleElementToHead(newStyleElement, 'pane', themeName);

                  narrowedCss = this.localThemeManager.narrowStyleScope(css, styleClass, "pane");
                  $(newStyleElement).text(narrowedCss);

                  var pane = atom.workspace.getActivePane();
                  var paneElem = this.localThemeManager.getActivePaneElem();

                  if (!this.elementLookup.get(pane)) {
                    this.elementLookup.set( pane, {} );
                  }

                  prevStyleClass = this.elementLookup.get(pane)['styleClass'];

                  if (prevStyleClass) {
                    this.localThemeManager.removeStyleElementFromHead(prevStyleClass);
                  }

                  $(paneElem).removeClass(prevStyleClass);
                  $(paneElem).addClass(styleClass);

                  // save the current element state in @elementLookup
                  elemState = this.elementLookup.get(pane);

                  if (!elemState[themeScope]) {
                    elemState[themeScope] = {};
                  }

                  elemState['type'] = themeScope;
                  elemState['styleClass'] = styleClass;
                  break;

                case "window":
                  styleClass = this.localThemeManager.addStyleElementToHead(newStyleElement, 'window', themeName);

                  narrowedCss = this.localThemeManager.narrowStyleScope(css, styleClass, "window");
                  $(newStyleElement).text(narrowedCss);

                  var windowElem = this.localThemeManager.getActiveWindowElem();

                  if (!this.elementLookup.get(windowElem)) {
                    this.elementLookup.set( windowElem, {} );
                  }

                  prevStyleClass = this.elementLookup.get(windowElem)['styleClass'];

                  if (prevStyleClass) {
                    this.localThemeManager.removeStyleElementFromHead(prevStyleClass);
                  }

                  $(windowElem).removeClass(prevStyleClass);
                  $(windowElem).addClass(styleClass);

                  // save the current element state in @elementLookup
                  elemState = this.elementLookup.get(windowElem);

                  if (!elemState[themeScope]) {
                    elemState[themeScope] = {};
                  }

                  elemState['type'] = themeScope;
                  elemState['styleClass'] = styleClass;
                  elemState['themePath'] = baseCssPath;
                  break;
              }
              // Reset all panes to avoid sympathetic bleed over effects that occasionally
              // happens when updating a non-activated (not currently focused) textEditor
              // in a pane.
              return this.utils.resetPanes();
            }
            ,err => console.log("promise returner err" + err));
      }

      destroy() {
        return this.selectorView.remove();
      }

      doIt() {
        return 7;
      }

      getElement() {
        return this.selectorView;
      }

      // return the active theme as a string
      //TODO: probably defunct as no one calls
      getCurrentGlobalSyntaxTheme() {
        const activePackages = atom.packages.getActivePackages();

        let activeTheme = '';

        for (let pkg of Array.from(activePackages)) {
          if (pkg.metadata.theme === 'syntax') {
              activeTheme = pkg.metadata.name;
            }
        }

        return activeTheme;
      }

      // reapply all the local themes as specified in the @fileLookup.
      // This is useful for when we first come back a sesion restore (i.e
      // cycling the editor)
      // Note: it turns out calling this is *not* necessary
      refreshAllLocalThemes() {
        return Array.from(this.fileLookup).map((fn, themePath) =>
          this.applyLocalTheme(fn(themePath)));
      }

      // For files that are themed under a "by file" or "by file type" scope, return
      // theme info: {theme: "C:/Users/vturner2/.atom/packages/ayu", scope: "FILE"}.
      //
      // The passed fn is fully qualified like : "D:/vtstuff_d/github/re-con/project.clj"
      // and the returned theme is also fully qualified: C:/Users/vturner2/.atom/packages/ayu
      // We do this because the most common source for the fn is 'utils.getActiveFile', which
      // returns a full path, and the dropdown menu has options for the theme that
      // are also full paths.
      // This is more a 'utils' type function, but if we put it in 'utils' we get
      // a cirucular dependency when 'utils' refers to 'LocalThemeSelectorView' (because
      // LocalThemeSelectorView already has a ref of its own to 'utils').
      getActiveThemeInfo(fn) {
         let activeTheme = null;
         let themeScope = null;
         let file_theme = this.fileLookup[fn];
         if (file_theme) {
           activeTheme= file_theme;
           themeScope = "FILE";
         }
         else {
           let ext = this.utils.getFileExt(fn);
           if( ext && Base.FileTypeLookup[ext]) {
             activeTheme = Base.FileTypeLookup[ext];
             themeScope = "FILE_TYPE";
           }
         }
         return {theme: activeTheme, scope: themeScope};
      }
    };

    LocalThemeSelectorView.initClass();
    return LocalThemeSelectorView;
  })());
