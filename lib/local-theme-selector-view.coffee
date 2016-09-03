# This is basically the main application class.  LocalThemeManager "should"
# probably be the main class, but LocalThemeSelectorView has kind taken over
# as the main focal point, with LocalThemeManager being more of a support 
# module.  This module should probably be renamed to drop the "view" from its
# name, as this # denotes it's only for the front-end view
#
# The point is, feel free to add non-view related functionality to this class.
$ = jQuery = require 'jquery'
{CompositeDisposable} = require 'atom'
Utils = require './utils'
LocalThemeManager = require './local-theme-manager'
LocalStylesElement  = require './local-styles-element'
fs = require('fs-plus')

module.exports =
  class LocalThemeSelectorView
    selectorView: null

    # this keeps track of the theme file locations
    # TODO: this should really be a hash and start with a lower-case letter
    ThemeLookup: []
    # keep track of the local theme applied by file.
    fileLookup: {} 

    constructor: (multiThemeApplicator) ->
      @multiThemeApplicator =  multiThemeApplicator

      # create all the supporting services we may need to call
      @localThemeManager = new LocalThemeManager()
      @localStylesElement = new LocalStylesElement()
      @utils = new Utils()

      # setup the pane listener, so we can automatically apply the local theme to any
      # new editors that show up.
      # @localThemeManager.initPaneEventHandler(this.applyLocalTheme)
      @localThemeManager.initPaneEventHandler(this)

      # create container element for the form
      @selectorView = document.createElement('div')
      @selectorView.classList.add('multi-theme-applicator','local-theme-selector-view')
      $('.local-theme-selector-view').attr( tabindex: '0')

      form = $('<form/>')
        .attr( id: 'input-form', class: 'apply-theme-form')
        .submit(
          (=> @applyLocalTheme),
        )

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

      closeModalDialogButton = $("<span>")
      closeModalDialogButton.attr(id: 'close-modal-dialog')
      closeModalDialogButton.text('x')
      closeModalDialogButton.appendTo(form)
      closeModalDialogButton.click(
        @multiThemeApplicator.toggle.bind(@multiThemeApplicator)
      )

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
        'local-theme-selector-view:expandThemeDropdown':  => @expandThemeDropdown()
        'local-theme-selector-view:multiThemeApplicatorToggle': => @multiThemeApplicator.toggle()
    # end ctor

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

    # simulate a mouse click on the theme dropdown, so the user can see
    # a larger selection.
    expandThemeDropdown: () ->
      element = $('#themeDropdown')[0]
      event = document.createEvent 'MouseEvents'
      event.initMouseEvent 'mousedown',true,true,window
      element.dispatchEvent event

    # Come here on submit
    applyLocalTheme: (themePath) ->
      baseCssPath = themePath || $( "#themeDropdown" ).val();
      sourcePath = baseCssPath + '/index.less'

      # Remember what theme is applied to what file.
      activeFile = @utils.getActiveURI()
      this.fileLookup[activeFile] = baseCssPath 

      promise = @localThemeManager.getThemeCss baseCssPath

      cssResult = null

      promise
        .then(
          (result) =>
            cssResult = result
            activeEditor = atom.workspace.getActiveTextEditor()
            activeURI = @utils.getActiveURI()

            params = {}
            params.uri = activeURI

            # get all the textEditors open for this file
            editors = @utils.getTextEditors params

            for editor in editors
              # We have to get a new styleElement each time i.e. we need to clone
              # it.  If we create just one styleElement outside of this loop, it will simply get reassigned
              # to the last editor we attach it too, and it won't be assigned to any of
              # the previous editors
              css = cssResult
              newStyleElement = @localStylesElement.createStyleElement(css, sourcePath)
              @localThemeManager.deleteThemeStyleNode(editor)
              @localThemeManager.addStyleElementToEditor(newStyleElement, editor)
              @localThemeManager.syncEditorBackgroundColor(editor)

            # Reset all panes to avoid sympathetic bleed over effects that occasionally
            # happens when updating a non-activated (not currently focused) textEditor
            # in a pane.
            @utils.resetPanes()
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
