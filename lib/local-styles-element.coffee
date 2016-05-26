$ = jQuery = require 'jquery'

module.exports =
  class LocalStylesElement

    constructor: ->

    doIt: ->
      7

    # create an html stle element suitable for injection onto an atom-text-editor
    createStyleElement: (css, sourcePath) ->
      styleElement = $('<style>')
        .attr('source-path', sourcePath)
        .attr('context', 'atom-text-editor')
        .attr('priority', '1')

      styleElement.text(css)

      styleElement[0]

    setEditorBackgroundColor: (backgroundColor) ->
      activeTextEditor = atom.workspace.getActiveTextEditor()
