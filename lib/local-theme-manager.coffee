$ = jQuery = require 'jquery'

module.exports =
  class LocalThemeManager

    constructor: ->

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

    doIt: ->
      getActivePackages = atom.packages.getActivePackages
      7
