/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const LocalThemeSelectorView = require('../lib/local-theme-selector-view');
const MultiThemeApplicator = require('../lib/multi-theme-applicator');
const LocalThemeManager = require('../lib/local-theme-manager');
//vt add
const Base = require('../lib/base');
//vt end

describe('LocalThemeSelectorView', function() {
  ({
    localThemeSelectorView: null,
    activationPromise: null
  });

  beforeEach(function() {
    // this is pretty ugly, but we have to do this since 'local-theme-selector-view'
    // needs to call certain methods in the package.  The package is a module and
    // not a normal class.
    this.multiThemeApplicatorMock = {
      toggle() {
        return "do nothing";
      }
    };

    //vt add
    // let ltsv = new LocalThemeSelectorView(this.multiThemeApplicatorMock);
    // reset fileLookup to empty, and let any individual tests override, as most tests
    // don't require 'this.localThemeSelectorView.fileLookup'.  If more test require this
    // then you might want to move the initializion from the test to here at the global level.
    // ltsv.fileLookup = {};
    // console.log("now driving beforeEach");
    // this.localThemeSelectorView = ltsv;
    // console.log("beforeEach: this.localThemeSelectorView=");
    // console.log(this.localThemeSelectorView);
    // console.log(ltsv);
    // return ltsv;
    //vt end
    return this.localThemeSelectorView = new LocalThemeSelectorView(this.multiThemeApplicatorMock);
    // return this.localThemeSelectorView = ltsv;
  });

  it('ctor works', function() {
    expect(this.localThemeSelectorView.localThemeManager).toBeDefined();
    expect(this.localThemeSelectorView.localThemeManager).toBeInstanceOf(LocalThemeManager);
    return expect(this.localThemeSelectorView.elementLookup).toBeInstanceOf(WeakMap);
  });

  it('doIt works', function() {
    console.log("hi from doIt ut");
    return expect(this.localThemeSelectorView.doIt()).toEqual(7);
  });

  // return it('getCurrentGlobalSyntaxTheme works', function() {
  //   let currentTheme;
  //   return currentTheme = this.localThemeSelectorView.getCurrentGlobalSyntaxTheme();
  // });

  //vt add
  it('getActiveThemeInfo works (red-meat non-edge cases)', function() {
    // let activeTheme;
    let fn_1 = "D:/vtstuff_d/github/re-con/project.clj";
    let theme_1 = "C:/Users/vturner2/.atom/packages/ayu";
    let fn_2 = "D:/vtstuff_d/github/re-con/src/cljs/re_con/base.cljs";
    let theme_2 = "C:/Users/vturner2/AppData/Local/atom/app-1.56.0/resources/app.asar/node_modules/atom-light-syntax"
    // this.localThemeSelectorView.prototype = {};
    // this.LocalThemeSelectorView.prototype.fileLookup = {"D:/vtstuff_d/github/re-con/project.clj": theme_1};
    // this.localThemeSelectorView.fileLookup = {"D:/vtstuff_d/github/re-con/project.clj": theme_1};
    this.localThemeSelectorView.fileLookup = {[fn_1]: theme_1, [fn_2]: theme_2};
    // this.localThemeSelectorView.prototype.fileLookup = {[fn_1]: theme_1, [fn_2]: theme_2};

    let tg_1 = "js";
    let group_theme_1 = "C:/Users/vturner2/.atom/packages/pear-syntax";
    Base.FileTypeLookup = {[tg_1]: group_theme_1};
    let fn_3 = "D:/vtstuff_d/github/re-con/karma.conf.js";

    let activeTheme_fn_1 = this.localThemeSelectorView.getActiveThemeInfo(fn_1);
    expect(typeof activeTheme_fn_1).toEqual("object");
    expect(activeTheme_fn_1.theme).toEqual(theme_1);
    expect(activeTheme_fn_1.scope).toEqual("FILE");
    //
    let activeTheme_fn_2 = this.localThemeSelectorView.getActiveThemeInfo(fn_2);
    // expect(activeTheme_fn_2).toEqual(theme_2);
    expect(typeof activeTheme_fn_2).toEqual("object");
    expect(activeTheme_fn_2.theme).toEqual(theme_2);
    expect(activeTheme_fn_2.scope).toEqual("FILE");
    //
    // // a .js file should return pear theme
    let activeTheme_tg_1 = this.localThemeSelectorView.getActiveThemeInfo(fn_3);
    // expect(activeTheme_tg_1).toEqual(group_theme_1);
    expect(typeof activeTheme_tg_1).toEqual("object");
    expect(activeTheme_tg_1.theme).toEqual(group_theme_1);
    expect(activeTheme_tg_1.scope).toEqual("FILE_TYPE");
  });

  it('dummy', function() {
    console.log("dummy");
    console.log(this.localThemeSelectorView);
    console.log("hi dummy ut: this.localThemeSelectorView.fileLookup=" + this.localThemeSelectorView.fileLookup);
  });
  //vt end
});
