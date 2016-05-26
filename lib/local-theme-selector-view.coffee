$ = jQuery = require 'jquery'
{CompositeDisposable} = require 'atom'
Utils = require './utils'
LocalThemeManager = require './local-theme-manager'
LocalStylesElement  = require './local-styles-element'
fs = require('fs-plus')

module.exports =
  class LocalThemeSelectorView
    selectorView: null

    ThemeLookup: []

    constructor: (multiThemeApplicator) ->
      @multiThemeApplicator = multiThemeApplicator
      # create all the supporting services we may need to call
      @localThemeManager = new LocalThemeManager()
      @localStylesElement = new LocalStylesElement()
      @utils = new Utils()
      # create container element for the form
      @selectorView = document.createElement('div')
      @selectorView.classList.add('local-theme-selector-view')
      $('.local-theme-selector-view').attr( tabindex: '0')

      form = $('<form/>')
        .attr( id: 'input-form', class: 'apply-theme-form')
        .submit( (@applyLocalTheme.bind @) )

      form.appendTo(@selectorView)

      $('<label>').text('Syntax Theme:').appendTo(form)

      @dropDownBorderWidthDefault
      themeDropdown = $('<select id="themeDropdown" name="selectTheme">')
      themeDropdown.focus =>
        @dropDownBorderWidthDefault = $('#themeDropdown').css('borderWidth')
        newBorderWidth = parseInt(@dropDownBorderWidthDefault) * 2.0
        $('#themeDropdown').css('borderWidth', newBorderWidth.toString());

      themeDropdown.blur =>
        $('#themeDropdown').css('borderWidth', @dropDownBorderWidthDefault);

      @themeLookup = @localThemeManager.getSyntaxThemeLookup()

      for theme in @themeLookup
        $('<option>', {
          value: theme.baseDir,
          text: theme.themeName})
        .appendTo(themeDropdown)

      themeDropdown.appendTo(form)

      $('<input id="apply-theme-submit"/>').attr(
        type: 'submit'
        value: 'Apply Local Theme'
      ).appendTo(form)

      # seed the initial active element.  This value will change as the user
      # selects via key bindings or mouse the selected theme in the dropdown.
      @themeLookupActiveIndex = 0

      @subscriptions = new CompositeDisposable

      # Register command that toggles this view
      @subscriptions.add atom.commands.add 'atom-workspace',
        'multi-theme-applicator:applyLocalTheme':  => @applyLocalTheme()
        'local-theme-selector-view:focusModalPanel':  => @focusModalPanel()

      @subscriptions.add atom.commands.add '.local-theme-selector-view',
        'local-theme-selector-view:applyLocalTheme':  => @applyLocalTheme()
        'local-theme-selector-view:selectPrevTheme':  => @selectPrevTheme()
        'local-theme-selector-view:selectNextTheme':  => @selectNextTheme()

    selectNextTheme: ->
      @themeLookupActiveIndex++
      @themeLookupActiveIndex %= @themeLookup.length

      $("#themeDropdown")
        .val @themeLookup[@themeLookupActiveIndex].baseDir

    selectPrevTheme: ->
      @themeLookupActiveIndex--
      if @themeLookupActiveIndex < 0
        @themeLookupActiveIndex = @themeLookup.length - 1

      $("#themeDropdown")
        .val(@themeLookup[@themeLookupActiveIndex].baseDir)

    focusModalPanel: () ->
      $('#themeDropdown').focus()

    # Come here on submit
    applyLocalTheme: ->
      baseCssPath = $( "#themeDropdown" ).val();
      sourcePath = baseCssPath + '/index.less'

      promise = @localThemeManager.getThemeCss baseCssPath

      cssResult = null

      promise
        .then(
          (result) =>
            cssResult = result
            css = cssResult
            newStyleElement = @localStylesElement.createStyleElement(css, sourcePath)

            @localThemeManager.deleteThemeStyleNode()
            @localThemeManager.addStyleElementToEditor(newStyleElement)
            @localThemeManager.syncEditorBackgroundColor()

            activeEditor = atom.workspace.getActiveTextEditor()

            # hack to get the new theme to activate
            @multiThemeApplicator.toggle()
            @multiThemeApplicator.toggle()
          ,(err) ->
            console.log "promise returner err" + err
        )

    destroy: ->
      @selectorView.remove()

    doIt: ->
      7

    getElement: ->
      return @selectorView

    # return the active theme as a string
    getCurrentGlobalSyntaxTheme: ->
      activePackages = atom.packages.getActivePackages()

      activeTheme = ''

      for pkg in activePackages
        if pkg.metadata.theme == 'syntax'
            activeTheme = pkg.metadata.name

      activeTheme
