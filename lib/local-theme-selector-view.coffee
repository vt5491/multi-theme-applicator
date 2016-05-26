$ = jQuery = require 'jquery'
{CompositeDisposable} = require 'atom'
Utils = require './utils'
LocalThemeManager = require './local-theme-manager'
LocalStylesElement  = require './local-styles-element'
fs = require('fs-plus')
# async = require('async')

module.exports =
  class LocalThemeSelectorView
    selectorView: null

    ThemeLookup: []
    packageBaseDir = '/home/vturner/.atom/packages/'
    LocalThemeSelectorView::ThemeLookup.push {themeName: 'choco', baseDir: "#{packageBaseDir}/choco" }
    LocalThemeSelectorView::ThemeLookup.push {themeName: 'humane-syntax', baseDir: "#{packageBaseDir}/humane-syntax" }
    LocalThemeSelectorView::ThemeLookup.push {themeName: 'seti-syntax', baseDir: "#{packageBaseDir}/seti-syntax" }
    #constructor: (serializedState)  ->
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
        console.log "now in themeDropdown focus handler"
        @dropDownBorderWidthDefault = $('#themeDropdown').css('borderWidth')
        console.log "dropDownBorderWidthDefault=" + @dropDownBorderWidthDefault
        newBorderWidth = parseInt(@dropDownBorderWidthDefault) * 2.0
        console.log "newBorderWidth=#{newBorderWidth}"
        #$(this).css('borderWidth', @dropDownBorderWidth * 2);
        #$('#themeDropdown').css('borderWidth', @dropDownBorderWidthDefault * 7);
        $('#themeDropdown').css('borderWidth', newBorderWidth.toString());
        #$('#themeDropdown').css('borderWidth', '7px');
        # $(this).css('background-color', 'red');
        console.log "now leaving themeDropdown focus handler"
        console.log "this.css.borderWidth=" + $('#themeDropdown').css('borderWidth')
        console.log "now leaving themeDropdown focus handler-2"

      themeDropdown.blur =>
        console.log "now in themeDropdown blur handler"
        #$(this).css('borderWidth', '2px');
        $('#themeDropdown').css('borderWidth', @dropDownBorderWidthDefault);

      #for i in LocalThemeSelectorView::ThemeLookup
      @themeLookup = @localThemeManager.getSyntaxThemeLookup()
      #for theme in LocalThemeSelectorView::ThemeLookup
      for theme in @themeLookup
        $('<option>', {
          value: theme.baseDir,
          text: theme.themeName})
        .appendTo(themeDropdown)

      themeDropdown.appendTo(form)
      #$('<br/>').appendTo(form)

      $('<input id="apply-theme-submit"/>').attr(
        type: 'submit'
        value: 'Apply Local Theme'
      ).appendTo(form)

      # seed the initial active element.  This value will change as the user
      # selects via key bindings or mouse the selected theme in the dropdown.
      @themeLookupActiveIndex = 0
      #themeDropdown.val(2)

      @subscriptions = new CompositeDisposable

      # Register command that toggles this view
      #@subscriptions.add atom.commands.add 'apply-theme-form',
      #@subscriptions.add atom.commands.add 'local-theme-selector-view',
      @subscriptions.add atom.commands.add 'atom-workspace',
        'multi-theme-applicator:applyLocalTheme':  => @applyLocalTheme()
        'local-theme-selector-view:focusModalPanel':  => @focusModalPanel()

      @subscriptions.add atom.commands.add '.local-theme-selector-view',
        'local-theme-selector-view:applyLocalTheme':  => @applyLocalTheme()
        'local-theme-selector-view:selectPrevTheme':  => @selectPrevTheme()
        'local-theme-selector-view:selectNextTheme':  => @selectNextTheme()

      # this has no effect when you do it as part of the constructor
      #$('#themeText').focus()

    selectNextTheme: ->
      #console.log "LocalThemeSelectorView.selectNextTheme: entered"
      @themeLookupActiveIndex++
      # @themeLookupActiveIndex %= LocalThemeSelectorView::ThemeLookup.length
      @themeLookupActiveIndex %= @themeLookup.length

      $("#themeDropdown")
        # .val(LocalThemeSelectorView::ThemeLookup[@themeLookupActiveIndex].baseDir)
        .val @themeLookup[@themeLookupActiveIndex].baseDir

    selectPrevTheme: ->
      # console.log "LocalThemeSelectorView.selectPrevTheme: entered"
      @themeLookupActiveIndex--
      if @themeLookupActiveIndex < 0
        # @themeLookupActiveIndex = LocalThemeSelectorView::ThemeLookup.length - 1
        @themeLookupActiveIndex = @themeLookup.length - 1

      $("#themeDropdown")
        #.val(LocalThemeSelectorView::ThemeLookup[@themeLookupActiveIndex].baseDir)
        .val(@themeLookup[@themeLookupActiveIndex].baseDir)

    focusModalPanel: () ->
      console.log "LocalThemeSelectorView.focusModalPanel: entered"
      #$('#themeText').trigger( "click")
      #$('#themeText').focus()
      $('#themeDropdown').focus()

    # Come here on submit
    applyLocalTheme: ->
      console.log('ThemeSelector.applyLocalTheme: entered 2')
      baseCssPath = $( "#themeDropdown" ).val();
      console.log("applyLocalTheme: baseCssPath=#{baseCssPath}")
      sourcePath = baseCssPath + '/index.less'

      promise = @localThemeManager.getThemeCss baseCssPath

      cssResult = null

      promise
        .then(
          (result) =>
            console.log "->promise return: css=" + result.substring(0,200)
            cssResult = result
            console.log "cssResult-2=" + cssResult.substring(0,200),
            css = cssResult
            newStyleElement = @localStylesElement.createStyleElement(css, sourcePath)
            # TODO: change name of method to indicate more clearly it *is* the active editor
            @localThemeManager.deleteThemeStyleNode()
            @localThemeManager.addStyleElementToEditor(newStyleElement)
            @localThemeManager.syncEditorBackgroundColor()

            activeEditor = atom.workspace.getActiveTextEditor()
            #activeEditor.setVisible true
            #atom.workspaceView.focus()
            # previouslyFocusedElement = $(':focus')
            #
            # activeEditor.getElement().focus()
            # atom.views.getView(atom.workspace).focus()
            #
            # # and then restore focus back to us against
            # previouslyFocusedElement.focus()
            @multiThemeApplicator.toggle()
            @multiThemeApplicator.toggle()
            #console.log "end of code"
            #activeEditor
          ,(err) ->
            console.log "promise returner err" + err
        )

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
