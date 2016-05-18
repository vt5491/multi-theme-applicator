$ = jQuery = require 'jquery'
# Utils = require './utils'

module.exports =
  class LocalThemeSelectorView
    selectorView: null

    #constructor: (serializedState)  ->
    constructor:  ->
      # create container element for the form
      @selectorView = document.createElement('div')
      @selectorView.classList.add('local-theme-selector-view')

      form = $('<form/>').attr( id: 'input-form').submit( (@applyLocalTheme.bind @) )

      form.appendTo(@selectorView)

      $('<input/>').attr(
        type: 'text'
        name: 'theme'
      ).appendTo(form)

      $('<input/>').attr(
        type: 'submit'
        value: 'Apply Local Theme'
      ).appendTo(form)

    applyLocalTheme: ->
      console.log('ThemeSelector.applyLocalTheme: entered')

    destroy: ->
      # this.element.remove()
      @selectorView.remove()

    doIt: ->
      7

    getElement: ->
      console.log('ThemeSelector.getElement: entered')
      return @selectorView

    # return the active theme as a string
    getCurrentGlobalSyntaxTheme: ->
      console.log('now in getCurrentGlobalSyntaxTheme')
      activePackages = atom.packages.getActivePackages()

      activeTheme = ''

      for pkg in activePackages
        if pkg.metadata.theme == 'syntax'
            activeTheme = pkg.metadata.name

      activeTheme
