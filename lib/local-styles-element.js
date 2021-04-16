/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let jQuery, LocalStylesElement;
const $ = (jQuery = require('jquery'));

module.exports =
  (LocalStylesElement = class LocalStylesElement {

    constructor() {}

    doIt() {
      return 7;
    }

    // create an html style element suitable for injection into an atom-text-editor
    createStyleElement(css, sourcePath) {
      const styleElement = $('<style>')
        .attr('source-path', sourcePath)
        .attr('context', 'atom-text-editor')
        .attr('priority', '1');

      styleElement.text(css);

      return styleElement[0];
    }

    setEditorBackgroundColor(backgroundColor) {
      let activeTextEditor;
      return activeTextEditor = atom.workspace.getActiveTextEditor();
    }
  });
