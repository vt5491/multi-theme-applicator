/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let jQuery, MultiThemeApplicator;
const $ = (jQuery = require('jquery'));
const Base = require('./base');
const Utils  = require('./utils');
const LocalThemeManager = require('./local-theme-manager');

const LocalThemeSelectorView = require('./local-theme-selector-view');
const {CompositeDisposable} = require('atom');
module.exports = (MultiThemeApplicator = {
  localThemeSelectorView: LocalThemeSelectorView,
  themeSelectorPanel: null,
  subscriptions: null,

  activate(state) {
    console.log("MultiThemeApplicator.activiate: entered v2.2.1 (js)");
    this.utils = new Utils();
    this.localThemeManager = new LocalThemeManager();
    this.localThemeSelectorView = new LocalThemeSelectorView(
      this, state['fileLookup'], state['FileTypeLookup'], state['ThemeLookup']);

    this.localThemeSelectorPanel = atom.workspace.addModalPanel({
      item: this.localThemeSelectorView.getElement(),
      visible: false
    });

    this.subscriptions = new CompositeDisposable;

    // Register the commands we want to appear in the palette.  These will only
    // show once MTA has been initialized e.g. after you've done a shift-ctrl-v
    // to bring up the theme dropdown.
    const cmdObj = {
      'multi-theme-applicator:toggle': () => this.toggle(),
      'multi-theme-applicator:reset': () => this.reset(),
      'multi-theme-applicator:refresh-theme-info': () => this.refreshThemeInfo()
    };

    this.subscriptions.add(atom.commands.add('atom-workspace', cmdObj));

    return this.utils = new Utils();
  },

  deactivate() {
    this.subscriptions.dispose();
    this.localThemeSelectorView.destroy();
    return this.localThemeSelectorPanel.destroy();
  },

  serialize() {
    const state = {};

    if(this.localThemeSelectorView && this.localThemeSelectorView.fileLookup) {
      state['fileLookup'] = this.localThemeSelectorView.fileLookup;
    }

    state['FileTypeLookup'] = Base.FileTypeLookup;
    state['ThemeLookup'] = Base.ThemeLookup;

    return state;
  },

  doIt() {
    return 7;
  },

  // Dynamically seed the theme dropdown with the active theme and scope based on the
  // current active editor.
  // If no prior theme applied, default to the last selected theme and scope of "file".
  seedThemeDropDown() {
    let activeFile = this.utils.getActiveFile();
    let activeThemeInfo, activeTheme, activeScope;

    if(activeFile) {
      activeThemeInfo = this.localThemeSelectorView.getActiveThemeInfo(activeFile);
      activeTheme = activeThemeInfo.theme;
      activeScope = activeThemeInfo.scope;
    }

    // seed theme
    if (activeTheme) {
      const el = document.getElementById('themeDropdown');
      let dropdownIdx = 0;
      let matchedIdx = null;
      for (option of el.options) {
        if (option.value === activeTheme) {
          matchedIdx = dropdownIdx;
          break;
        }
        dropdownIdx++;
      }
      if (matchedIdx) {
        // update the current view
        el.options.selectedIndex = matchedIdx;
        // and also our backend state
        this.localThemeSelectorView.themeLookupActiveIndex = matchedIdx;
      }
    }
    // seed scope radio button (file or filtype only for now)
    if (!activeScope || activeScope === "FILE") {
      const fileScopeBtn = $("input[type='radio'][name='scope'][value='file']");
      if(fileScopeBtn) {
        fileScopeBtn.prop("checked", true);
      }
    }
    else if (activeScope === "FILE_TYPE") {
      const fileTypeScopeBtn = $("input[type='radio'][name='scope'][value='fileType']");
      if(fileTypeScopeBtn) {
        fileTypeScopeBtn.prop("checked", true);
      }
    }
  },

  toggle() {
    if (this.localThemeSelectorPanel.isVisible()) {
      this.localThemeSelectorPanel.hide();
      if (atom.workspace.getActiveTextEditor()) {
        return atom.workspace.getActiveTextEditor().getElement().focus();
      }
    } else {
      this.seedThemeDropDown();
      this.localThemeSelectorPanel.show();
      // and give the dropdown keyboard focus
      return this.localThemeSelectorView.focusModalPanel();
    }
  },

  reset() {
    for (let editor of Array.from(atom.workspace.getTextEditors())) {
      var editorInfo;
      if (editorInfo = Base.ElementLookup.get(editor)) {
        if (editorInfo['editor']) {
          this.localThemeSelectorView.localThemeManager.removeScopedTheme('editor', editor);
        }
        if (editorInfo['file']) {
          this.localThemeSelectorView.localThemeManager.removeScopedTheme('file', editor);
        }
        if (editorInfo['fileType']) {
          this.localThemeSelectorView.localThemeManager.removeScopedTheme('fileType', editor);
        }
      }
    }
    for (let pane of Array.from(atom.workspace.getPanes())) {
      var paneInfo;
      if (paneInfo = Base.ElementLookup.get(pane)) {
        this.localThemeSelectorView.localThemeManager.removeScopedTheme('pane', pane);
      }
    }

    const windowElem = this.localThemeManager.getActiveWindowElem();
    if (Base.ElementLookup.get(windowElem)) {
      this.localThemeSelectorView.localThemeManager.removeScopedTheme('window', windowElem);
    }


    this.localThemeSelectorView.fileLookup = {};
    return Base.FileTypeLookup = {};
  },
    // Note: be careful about clearing out the ElementLookup WeakMap.  There seems
    // to be issue if you clear this out without also doing a shitf-ctrl-f5 resetPanes
    // or cycling atom (in other words resetting with one atom session)
    // Base.ElementLookup = new WeakMap()

  refreshThemeInfo() {
    return this.localThemeSelectorView.refreshThemeInfo();
  }
});
