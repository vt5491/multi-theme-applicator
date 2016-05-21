$ = jQuery = require 'jquery'
Utils = require './utils'
LocalThemeManager = require './local-theme-manager'
LocalStylesElement  = require './local-styles-element'

module.exports =
  class LocalThemeSelectorView
    selectorView: null

    #constructor: (serializedState)  ->
    constructor:  ->
      # create all the supporting services we may need to call
      @localThemeManager = new LocalThemeManager()
      @localStylesElement = new LocalStylesElement()
      @utils = new Utils()
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

    # Come here on submit
    applyLocalTheme: ->
      console.log('ThemeSelector.applyLocalTheme: entered')
      # css = ''
      # @localThemeManager.getThemeCss().then (result) =>
      #   css = result
      # , (err) ->
      #   console.log "promise returned with err=" + err
      css = @utils.getHumaneCssString()

      console.log "css=" + css
      # LSE.createStyleElement
      # p.s. the sourcePath is just important for cosmetic reasons.  It could
      # actualy be anything
      sourcePath = '/home/vturner/.atom/packages/humane-syntax/index.less'
      newStyleElement = @localStylesElement.createStyleElement(css, sourcePath)
      # LTM.deleteThemeStyleNode
      # This goes against the active editor
      # TODO: change name of method to indicate more clearly it *is* the active editor
      @localThemeManager.deleteThemeStyleNode()
      # LTM.addStyleElementToEditor
      @localThemeManager.addStyleElementToEditor(newStyleElement)
      # LTM.syncEditorBackgroundColor
      @localThemeManager.syncEditorBackgroundColor()

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
