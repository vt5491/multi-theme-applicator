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

    # updateParentBGColor: ->
    #   console.log('now in updateParentBGColor')
    #   node1 = $('.pane').eq(1)
    #   shadowRoot = $('.pane').eq(1).find('atom-text-editor').eq(0)[0].shadowRoot
    #
    #   node3 = $(shadowRoot)
    #   .find('atom-styles')
    #   .find('style').last()
    #
    #   console.log('updateParentBGColor: node3=' + node3)
    #   #node3
    #   bgColor = node3[0].sheet.rules[0].style.backgroundColor
    #   console.log('updateParentBGColor: bgColor=' + bgColor)
    #
    #   baseEl = $('.pane').eq(1).find('atom-text-editor')
    #     .attr('style', 'background-color: ' + bgColor)
    #   console.log('updateParentBGColor: baseEl=' + baseEl)

    setEditorBackgroundColor: (backgroundColor) ->
      #shadowRoot = @utils.getActiveShadowRoot()
      activeTextEditor = atom.workspace.getActiveTextEditor()

      # $(activeTextEditor).css('background-color', backgroundColor)
      # console.log "setEditorBackgroundColor: new bg color="
      #   + $(activeTextEditor).css('background-color')


    # sync the background color of the parent to that of the local theme
    # syncEditorBackgroundColor: () ->
