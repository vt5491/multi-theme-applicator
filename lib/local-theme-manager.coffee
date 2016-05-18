$ = jQuery = require 'jquery'
Utils = require './utils'

module.exports =
  class LocalThemeManager

    constructor: ->
      @utils = new Utils()

    doIt: ->
      getActivePackages = atom.packages.getActivePackages
      7

    # return the active theme as a string
    getActiveSyntaxTheme: ->
      console.log('LocalThemeManager.getActiveSyntaxTheme: entered')
      getActivePackages = atom.packages.getActivePackages
      # console.log('*******LocalThemeManager.getActiveSyntaxTheme: getActivePackages=' + getActivePackages + "\n")
      # console.log('***********************LocalThemeManager.getActiveSyntaxTheme: getActivePackages()=' + getActivePackages() + "\n")
      activePackages = atom.packages.getActivePackages()

      activeTheme = ''

      for pkg in activePackages
        if pkg.metadata.theme == 'syntax'
            activeTheme = pkg.metadata.name

      activeTheme

    deleteThemeNode: ->
      console.log('LocalThemeManager.deleteThemeNode: now in deleteThemeNode')
      #node = $('atom-pane-axis:nth-child(2)')
      #node = $('atom-pane:eq(2)')
      #node1 = $('.pane:eq(1)')
      # node1 = $('.pane').eq(1)
      #node2 = $('atom-text-editor:eq(1)', node1)

      #node2 = $('.pane:eq(1) atom-text-editor:eq(1)')
      # shadowRoot = $('.pane').eq(1).find('atom-text-editor').eq(0)[0].shadowRoot
      shadowRoot = @utils.getActiveShadowRoot()
      # shadowRoot = $('.pane').eq(1)
      #   .find('atom-text-editor::shadow').eq(0)
      console.log('deleteThemeNode: shadowRoot=' + shadowRoot)

      #jShadowRoot = $(shadowRoot)
      #node3 = jShadowRoot.$('atom-styles')
      node3 = $(shadowRoot)
        .find('atom-styles')
        .find('style').eq(0)
      #node3 = shadowRoot.find('atom-styles')
      console.log('deleteThemeNode: node3=' + node3)
      # node3.remove()
      $(node3).remove()
      console.log('deleteThemeNode: deleted node3')
