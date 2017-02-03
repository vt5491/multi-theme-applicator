$ = jQuery = require 'jquery'
{CompositeDisposable} = require 'atom'
Utils = require './utils'
LocalThemeManager = require './local-theme-manager'
LocalStylesElement  = require './local-styles-element'
Base = require './base'
fs = require('fs-plus')

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

# @themeLookup
# Is basically just a directory of themes and where the theme file is located.
# It's an array of objects.  Each object has two keys: 'themeName' and 'baseDir'
# Object {themeName: "choco", baseDir: "C:/Users/vturner/.atom/packages/choco"}
#
# baseDir:"C:/Users/vturner/.atom/packages/choco"
# themeName:"choco"
#
# i.e. It is not used for keeping track of what theme is applied to what file etc.

# @elementLookup
# defined in Base
# Used to keep track of elements that we have styled.  It's a WeakMap.  The key
# is the dom element (not jquery Element). We associate a js object with this key.
# The keys in the js object are:
# type, theme, class
#
## jqPath: a path that you can pass to jquery such that it will uniquely identify the element.
##  note: use utils->getEditorPath, getPanePath, getWindowPath to get a normalized
##        and standard jqPath
# type: The style scope: {windows, pane, file, editor}
# theme: the theme applied e.g "fairyfloss"
# styleClass: the style tag that has been added to the element's class e.g. 'mta-editor-style-1484974763214'

module.exports =
  class LocalThemeSelectorView
    selectorView: null

    # this keeps track of the theme file locations
    # themeLookup: []
    #vt add
    # themeLookup = Base.ThemeLookup
    #vt end
    # keep track of the local theme applied by file.
    fileLookup: {}
    # keep track of the state of each element we apply a local theme to.
    elementLookup: WeakMap

    constructor: (multiThemeApplicator, fileLookupState) ->
      @multiThemeApplicator =  multiThemeApplicator
      # restore the prior fileLookupState, if any
      @fileLookup = fileLookupState
      @elementLookup = Base.ElementLookup
      # vt-x@themeLookup = Base.ThemeLookup

      # create all the supporting services we may need to call
      @localThemeManager = new LocalThemeManager()
      @localStylesElement = new LocalStylesElement()
      @utils = new Utils()

      this.initThemeSelectorForm()
      # setup the pane listener, so we can automatically apply the local theme to any
      # new editors that show up.
      @localThemeManager.initPaneEventHandler(this)

      # setup pane close events so we can delete any styling context
      @localThemeManager.initOnDidDestroyPaneHandler()
      # setup pane item close events (e.g editor closings) so we can delete any styling context
      @localThemeManager.initOnDidDestroyPaneItem()
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

    initThemeSelectorForm: ->
      # create container element for the form
      @selectorView = document.createElement('div')
      @selectorView.classList.add('multi-theme-applicator','local-theme-selector-view')
      $('.local-theme-selector-view').attr( tabindex: '0')

      $form = $('<form/>')
        .attr( id: 'input-form', class: 'apply-theme-form')
        .submit(=> @applyLocalTheme())

      $form.appendTo(@selectorView)

      $themeDiv = $('<div class="theme"></div>')
      $form.append($themeDiv)

      $('<label>').text('Syntax Theme:').appendTo($themeDiv)

      @dropDownBorderWidthDefault
      $themeDropdown = $('<select id="themeDropdown" name="selectTheme">')
      $themeDropdown.focus =>
        @dropDownBorderWidthDefault = $('#themeDropdown').css('borderWidth')
        newBorderWidth = parseInt(@dropDownBorderWidthDefault) * 2.0
        $('#themeDropdown').css('borderWidth', newBorderWidth.toString());

      $themeDropdown.blur =>
        $('#themeDropdown').css('borderWidth', @dropDownBorderWidthDefault);

      # @themeLookup = @localThemeManager.getSyntaxThemeLookup()
      #
      # # sort themeLookup by theme name. Note: sort is desctructive, so it alters the original
      # @themeLookup.sort (a,b) ->
      #   nameA=a.themeName.toLowerCase()
      #   nameB=b.themeName.toLowerCase()
      #   if nameA < nameB
      #     return -1
      #   if nameA > nameB
      #     return 1
      #   return 0
      #
      # for theme in @themeLookup
      #   $('<option>', {
      #     value: theme.baseDir,
      #     text: theme.themeName})
      #   .appendTo($themeDropdown)
      this.refreshThemeInfo($themeDropdown)

      # register a listener for onChange, so we can clear any error messages from
      # the last selection
      $themeDropdown.change(() =>
        $('#input-form span.error').text('')
        $('#input-form span.error').css("visibility", "hidden") )

      $themeDropdown.appendTo($themeDiv)

      # $themeDropdown.html('')

      closeModalDialogButton = $("<span>")
      closeModalDialogButton.attr(id: 'close-modal-dialog')
      closeModalDialogButton.text('x')
      closeModalDialogButton.appendTo($themeDiv)
      closeModalDialogButton.click(
        @multiThemeApplicator.toggle.bind(@multiThemeApplicator)
      )

      $scopeDiv = $('<div class="scope"></div>').appendTo($form)
      $('<label>').text('Scope:').appendTo($scopeDiv)
      $('<input type="radio" name="scope" value="window">Window</input>').appendTo($scopeDiv)
      $('<input type="radio" name="scope" value="pane">Pane</input>').appendTo($scopeDiv)
      $('<input type="radio" name="scope" value="file" checked>File</input>').appendTo($scopeDiv)
      $('<input type="radio" name="scope" value="editor">Editor</input>').appendTo($scopeDiv)

      $submitDiv = $('<div class="submit"></div>')
      $form.append $submitDiv

      $submitBtn = $('<button type="submit" form="input-form" value="Apply Scoped Theme">Apply Scoped Theme</button>')
      $submitBtn.appendTo $submitDiv

      $removeScopedThemeBtn = $('<button type="button"></button>')
      $removeScopedThemeBtn.text('Remove Scoped Theme')
      $removeScopedThemeBtn.attr('id', 'remove-scoped-theme')
      $removeScopedThemeBtn.appendTo($submitDiv)
      $removeScopedThemeBtn.click () =>
        scope = $('input[name=scope]:checked').val()
        @localThemeManager.removeScopedTheme(scope)
        # return false so the main submit action is not applied
        return false

    #vt add
    refreshThemeInfo: ($themeDropdown) ->
      console.log "LocalThemeManagerSelectorView.refreshThemeInfo: entered"
      $dropDown = $themeDropdown ? $('#themeDropdown')
      # @themeLookup = @localThemeManager.getSyntaxThemeLookup()
      Base.ThemeLookup = @localThemeManager.getSyntaxThemeLookup()
      # themeDropdownHtml = @localThemeManager.getThemeDropdownHtml(@themeLookup)
      themeDropdownHtml = @localThemeManager.getThemeDropdownHtml(Base.ThemeLookup)
      # $('#themeDropdown').html(themeDropdownHtml)
      $dropDown.html(themeDropdownHtml)
    #vt end

    selectNextTheme: ->
      @themeLookupActiveIndex++
      # @themeLookupActiveIndex %= @themeLookup.length
      @themeLookupActiveIndex %= Base.ThemeLookup.length

      $("#themeDropdown")
        .val @themeLookup[@themeLookupActiveIndex].baseDir

    selectPrevTheme: ->
      @themeLookupActiveIndex--
      if @themeLookupActiveIndex < 0
        # @themeLookupActiveIndex = @themeLookup.length - 1
        @themeLookupActiveIndex = Base.ThemeLookup.length - 1

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

    # Come here on submit.  Apply a theme at the window level, not the individual editor
    # level.
    # This is the key method of the whole package.  This basically drives all the
    # other supporting modules.
    applyLocalTheme: (fn, themePath) ->
      themeScope = $("input[type='radio'][name='scope']:checked").val()

      if !themeScope
        console.log "LocalThemeSelectorView.applyLocalTheme: skipping because no themeScope"
        return

      baseCssPath = themePath || $( "#themeDropdown" ).val();
      console.log "LocalThemeSelectorView.applyLocalTheme: themeName=#{@utils.getThemeName(baseCssPath)}"
      #vt add
      themeName = @utils.getThemeName baseCssPath
      #vt end
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

            # attempt to normalize normalize pre atom 1.13 themes
            if !css.match /\.syntax--comment/gm
              css = @localThemeManager.normalizeSyntaxScope css

            newStyleElement = @localStylesElement.createStyleElement(css, sourcePath)

            switch themeScope
              when "file", "editor"
                #vt-xstyleClass = @localThemeManager.addStyleElementToHead(newStyleElement, themeScope)
                styleClass = @localThemeManager.addStyleElementToHead(newStyleElement, themeScope, themeName)

                narrowedCss = @localThemeManager.narrowStyleScope(css, styleClass, themeScope)
                $(newStyleElement).text(narrowedCss)

                params = {}

                params.uri = fn || @utils.getActiveFile()

                editors = []
                if themeScope == "file"
                  # get all the textEditors open for this file
                  editors = @utils.getTextEditors params
                else
                  editors.push atom.workspace.getActiveTextEditor()

                for editor in editors
                  # We have to get a new styleElement each time i.e. we need to clone
                  # it.  If we create just one styleElement outside of this loop, it will simply get reassigned
                  # to the last editor we attach it too, and it won't be assigned to any of
                  # the previous editors
                  editorElem = editor.getElement();

                  if !@elementLookup.get editor
                    # create a two-tier lookup element->'file'
                    @elementLookup.set editor, {"#{themeScope}" : {} }

                  if @elementLookup.get(editor) && @elementLookup.get(editor)[themeScope]
                    prevStyleClass = @elementLookup.get(editor)[themeScope]['styleClass']

                  # since multiple editors can be associated with one head style
                  # we will typically be deleting the head style multiple times, but the
                  # operation is idempotent, so this is safe.  By the time we determine
                  # that we don't need to delete it, we could have already gone ahead and
                  # just deleted it.  So it's easier and simpler to just delete it multiple times.
                  if prevStyleClass
                    @localThemeManager.removeStyleElementFromHead(prevStyleClass)

                  $(editorElem).removeClass(prevStyleClass)
                  $(editorElem).addClass(styleClass)

                  # save the current element state in @elementLookup
                  elemState = @elementLookup.get(editor)

                  if !elemState[themeScope]
                    elemState[themeScope] = {}

                  elemState[themeScope]['type'] = themeScope
                  elemState[themeScope]['styleClass'] = styleClass

              when "pane"
                styleClass = @localThemeManager.addStyleEleme
                ntToHead(newStyleElement, 'pane', themeName)

                narrowedCss = @localThemeManager.narrowStyleScope(css, styleClass, "pane")
                $(newStyleElement).text(narrowedCss)

                pane = atom.workspace.getActivePane()
                paneElem = $('atom-pane.active')[0]

                if !@elementLookup.get pane
                  @elementLookup.set( pane, {} )

                prevStyleClass = @elementLookup.get(pane)['styleClass']

                if prevStyleClass
                  @localThemeManager.removeStyleElementFromHead(prevStyleClass)

                $(paneElem).removeClass(prevStyleClass)
                $(paneElem).addClass(styleClass)

                # save the current element state in @elementLookup
                elemState = @elementLookup.get(pane)

                if !elemState[themeScope]
                  elemState[themeScope] = {}

                elemState['type'] = themeScope
                elemState['styleClass'] = styleClass

              when "window"
                styleClass = @localThemeManager.addStyleElementToHead(newStyleElement, 'window', themeName)

                narrowedCss = @localThemeManager.narrowStyleScope(css, styleClass, "window")
                $(newStyleElement).text(narrowedCss)

                windowElem = $('atom-pane-container.panes')[0]

                if !@elementLookup.get windowElem
                  @elementLookup.set( windowElem, {} )

                prevStyleClass = @elementLookup.get(windowElem)['styleClass']

                if prevStyleClass
                  @localThemeManager.removeStyleElementFromHead(prevStyleClass)

                $(windowElem).removeClass(prevStyleClass)
                $(windowElem).addClass(styleClass)

                # save the current element state in @elementLookup
                elemState = @elementLookup.get(windowElem)

                if !elemState[themeScope]
                  elemState[themeScope] = {}

                elemState['type'] = themeScope
                elemState['styleClass'] = styleClass
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
