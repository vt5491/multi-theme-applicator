# This is basically the main application class.  LocalThemeManager "should"
# probably be the main class, but LocalThemeSelectorView has kind taken over
# as the main focal point, with LocalThemeManager being more of a support
# module.  This module should probably be renamed to drop the "view" from its
# name, as this denotes it's only for the front-end view
#
# The point is, feel free to add non-view related functionality to this class.

# Data Structure documentation:
# @fileLookup
# the key is the name of the file in the editor.  The value is fully qualified path
# to the style that is applied to it.
# Example:
# C:/vtstuff/github/multi-theme-applicator/lib/local-styles-element.coffee
# :
# "C:/Users/vturner/AppData/Local/atom/app-1.13.0/resources/app.asar/node_modules/atom-light-syntax"
# C:/vtstuff/github/multi-theme-applicator/lib/multi-theme-applicator.coffee
# :
# "C:/Users/vturner/.atom/packages/fairyfloss"

# @ themeLookup
# Is basically just a directory of themes and where the theme file is located.
# It's an array of objects.  Each object has two keys: 'themeName' and 'baseDir' 
# Object {themeName: "choco", baseDir: "C:/Users/vturner/.atom/packages/choco"}
#
# baseDir:"C:/Users/vturner/.atom/packages/choco"
# themeName:"choco"
#
# i.e. It is not used for keeping track of what theme is applied to what file etc.

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
    themeLookup: []
    # keep track of the local theme applied by file.
    fileLookup: {}

    constructor: (multiThemeApplicator, fileLookupState) ->
      @multiThemeApplicator =  multiThemeApplicator
      # restore the prior fileLookupState, if any
      @fileLookup = fileLookupState

      # create all the supporting services we may need to call
      @localThemeManager = new LocalThemeManager()
      @localStylesElement = new LocalStylesElement()
      @utils = new Utils()

      # setup the pane listener, so we can automatically apply the local theme to any
      # new editors that show up.
      #vt tmp comment out
      #vt-x @localThemeManager.initPaneEventHandler(this)

      # create container element for the form
      @selectorView = document.createElement('div')
      @selectorView.classList.add('multi-theme-applicator','local-theme-selector-view')
      $('.local-theme-selector-view').attr( tabindex: '0')

      form = $('<form/>')
        .attr( id: 'input-form', class: 'apply-theme-form')
        #vt.submit(=> @applyLocalTheme())
        .submit(=> @applyLocalTheme())

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
        #vt 'multi-theme-applicator:applyLocalTheme':  => @applyLocalTheme()
        'multi-theme-applicator:applyLocalTheme':  => @applyLocalTheme()
        'local-theme-selector-view:focusModalPanel':  => @focusModalPanel()

      @subscriptions.add atom.commands.add '.local-theme-selector-view',
        #vt'local-theme-selector-view:applyLocalTheme':  => @applyLocalTheme()
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

    # # Come here on submit
    # applyLocalTheme: (fn, themePath) ->
    #   baseCssPath = themePath || $( "#themeDropdown" ).val();
    #   sourcePath = baseCssPath + '/index.less'

    #   # Remember what theme is applied to what file.
    #   targetFile = fn || @utils.getActiveFile()
    #   @fileLookup[targetFile] = baseCssPath

    #   promise = @localThemeManager.getThemeCss baseCssPath

    #   cssResult = null

    #   promise
    #     .then(
    #       (result) =>
    #         cssResult = result

    #         params = {}

    #         params.uri = fn || @utils.getActiveFile()

    #         # get all the textEditors open for this file
    #         editors = @utils.getTextEditors params

    #         for editor in editors
    #           # We have to get a new styleElement each time i.e. we need to clone
    #           # it.  If we create just one styleElement outside of this loop, it will simply get reassigned
    #           # to the last editor we attach it too, and it won't be assigned to any of
    #           # the previous editors
    #           css = cssResult
    #           newStyleElement = @localStylesElement.createStyleElement(css, sourcePath)
    #           @localThemeManager.deleteThemeStyleNode(editor)
    #           @localThemeManager.addStyleElementToEditor(newStyleElement, editor)
    #           # @localThemeManager.syncEditorBackgroundColor(editor)

    #         # Reset all panes to avoid sympathetic bleed over effects that occasionally
    #         # happens when updating a non-activated (not currently focused) textEditor
    #         # in a pane.
    #         @utils.resetPanes()
    #       ,(err) ->
    #         console.log "promise returner err" + err
    #     )

    # Come here on submit.  Apply a theme at the window level, not the individual editor
    # level.  This is all we seem to be able to post Atom 1.13
    applyLocalTheme: (fn, themePath) ->
      console.log "LocalThemeSelectorView.applyLocalTheme: entered"
      baseCssPath = themePath || $( "#themeDropdown" ).val();
      sourcePath = baseCssPath + '/index.less'

      # Remember what theme is applied to what file.
      targetFile = fn || @utils.getActiveFile()
      @fileLookup[targetFile] = baseCssPath

      promise = @localThemeManager.getThemeCss baseCssPath

      # css = null
      styleElement = null

      promise
        .then(
          (result) =>
            css = result
            # css = $(styleElement).text()

            params = {}

            params.uri = fn || @utils.getActiveFile()

            #vt add
            newStyleElement = @localStylesElement.createStyleElement(css, sourcePath)
            styleClass = @localThemeManager.addStyleElementToHead(newStyleElement, editor)

            narrowedCss = @localThemeManager.narrowStyleScope(css, styleClass)
            $(newStyleElement).text(narrowedCss)
            #vt end

            # get all the textEditors open for this file
            editors = @utils.getTextEditors params

            for editor in editors
              # We have to get a new styleElement each time i.e. we need to clone
              # it.  If we create just one styleElement outside of this loop, it will simply get reassigned
              # to the last editor we attach it too, and it won't be assigned to any of
              # the previous editors
              # css = cssResult
              # newStyleElement = @localStylesElement.createStyleElement(css, sourcePath)
              # @localThemeManager.deleteThemeStyleNode(editor)
              # @localThemeManager.deleteThemeStyleNodeFromHead(editor)
              # @localThemeManager.addStyleElementToEditor(newStyleElement, editor)
              $(editor.getElement()).addClass(styleClass)
              # $(editor.getElement()).parent().addClass(styleClass)
              #vt @localThemeManager.syncEditorBackgroundColor(editor)

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

    # reapply all the local themes as specified in the @fileLookup.
    # This is useful for when we first come back a sesion restore (i.e
    # cycling the editor)
    # Note: it turns out calling this is *not* necessary
    refreshAllLocalThemes: () ->
      for fn, themePath in @fileLookup
        @applyLocalTheme fn themePath
