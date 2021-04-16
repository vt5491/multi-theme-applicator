/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Base;
module.exports =
  (Base = (function() {
    Base = class Base {
      static initClass() {
  
    // @elementLookup
    // Used to keep track of elements that we have styled.  It's a WeakMap.  The key
    // is the dom element (not jquery Element). We associate a js object with this key.
    // The keys in the js object are:
    // type, theme, class
    //
    // type: The style scope: {windows, pane, file, editor}
    // theme: the theme applied e.g "fairyfloss"
    // styleClass: the style tag that has been added to the element's class e.g. 'mta-editor-style-1484974763214'
        // refer to this class var as Base.ElementLookup in other classes (not as Base.@ElementLookup)
        this.ElementLookup = new WeakMap();
        this.ThemeLookup = [];
        this.FileTypeLookup = {};
      }
    };
    Base.initClass();
    return Base;
  })());
