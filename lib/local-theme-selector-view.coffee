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

# Base.FileTypeLookup:
# key: the file extension e.g. 'ts', 'js'
# value: the fully qualified css path to the theme for this file type

module.exports =
  class LocalThemeSelectorView
    selectorView: null

    # keep track of the local theme applied by file.
    fileLookup: {}
    # keep track of the state of each element we apply a local theme to.
    elementLookup: WeakMap

    constructor: (multiThemeApplicator, prevSessionFileLookupState, prevSessionFileTypeLookupState, prevThemeLookupState) ->
      # console.log "LocalThemeSelectorView.ctor: entered"
      @multiThemeApplicator =  multiThemeApplicator
      # restore the prior fileLookupState, if any
      @fileLookup = prevSessionFileLookupState || {}
      @elementLookup = Base.ElementLookup
      Base.FileTypeLookup = prevSessionFileTypeLookupState || {}
      Base.ThemeLookup = prevThemeLookupState || []

      # create all the supporting services we may need to call
      @localThemeManager = new LocalThemeManager()
      @localStylesElement = new LocalStylesElement()
      @utils = new Utils()

      this.reapplyThemes()
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

      this.refreshThemeInfo($themeDropdown)

      # register a listener for onChange, so we can clear any error messages from
      # the last selection
      $themeDropdown.change(() =>
        $('#input-form span.error').text('')
        $('#input-form span.error').css("visibility", "hidden") )

      $themeDropdown.appendTo($themeDiv)

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
      $('<input type="radio" name="scope" value="fileType" checked>FileType</input>').appendTo($scopeDiv)
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

    reapplyThemes: () ->
      # fileType
      if Base.FileTypeLookup && Object.keys(Base.FileTypeLookup).length > 0
        for fileType in Object.keys Base.FileTypeLookup
          themePath = Base.FileTypeLookup[fileType]
          for editor in atom.workspace.getTextEditors()
            fs.stat themePath, (err, stats) =>
              if err
                console.log "LocalThemeSelectorView.reapplyThemes: skipping fileType theme reapplication: error=#{err}"
                return

              editorFile = @utils.getActiveFile editor
              fileExt = @utils.getFileExt editorFile

              if fileExt == fileType
                this.applyLocalTheme editorFile, themePath, 'fileType', editor

      # file scope files
      if @fileLookup && Object.keys(@fileLookup).length > 0
        for filePath in Object.keys @fileLookup
          themePath = @fileLookup[filePath]
          # console.log "themePath=#{themePath},exists=#{fs.exists themePath}"
          fs.stat themePath, (err, stats) =>
            if err
              console.log "LocalThemeSelectorView.reapplyThemes: skipping file theme reapplication: error=#{err}"
              return

            for editor in atom.workspace.getTextEditors()
              if @utils.getActiveFile(editor) == filePath
                this.applyLocalTheme filePath, themePath, 'file', editor

      true

    refreshThemeInfo: ($themeDropdown) ->
      $dropDown = $themeDropdown ? $('#themeDropdown')
      Base.ThemeLookup = @localThemeManager.getSyntaxThemeLookup()
      themeDropdownHtml = @localThemeManager.getThemeDropdownHtml(Base.ThemeLookup)
      $dropDown.html(themeDropdownHtml)

    selectNextTheme: ->
      @themeLookupActiveIndex++
      @themeLookupActiveIndex %= Base.ThemeLookup.length

      $("#themeDropdown")
        .val(Base.ThemeLookup[@themeLookupActiveIndex].baseDir).attr('name')

    selectPrevTheme: ->
      @themeLookupActiveIndex--
      if @themeLookupActiveIndex < 0
        @themeLookupActiveIndex = Base.ThemeLookup.length - 1

      $("#themeDropdown")
        .val(Base.ThemeLookup[@themeLookupActiveIndex].baseDir).attr('name')

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
    applyLocalTheme: (fn, themePath, scope, ed) ->
      themeScope = scope || $("input[type='radio'][name='scope']:checked").val()

      if !themeScope
        console.log "LocalThemeSelectorView.applyLocalTheme: skipping because no themeScope"
        return

      baseCssPath = themePath || $( "#themeDropdown" ).val();
      themeName = @utils.getThemeName baseCssPath
      sourcePath = baseCssPath + '/index.less'

      targetFile = fn || @utils.getActiveFile()
      # get the "ts" from "myfile.ts", for example
      fileExt = @utils.getFileExt targetFile

      # an fn arg means this is an application to a file that falls under an
      # existing rule.  Therefore, we don't need to save it's theme state, as it
      # should already be covered by another file or fileExt.
      if !fn
        if themeScope == "file" || themeScope == "editor"
          # Remember what theme is applied to what file.
          @fileLookup[targetFile] = baseCssPath

        else if themeScope == "fileType"
          Base.FileTypeLookup[fileExt] = baseCssPath

      promise = @localThemeManager.getThemeCss baseCssPath

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
              when "fileType", "file", "editor"
                styleClass = @localThemeManager.addStyleElementToHead(newStyleElement, themeScope, themeName)

                narrowedCss = @localThemeManager.narrowStyleScope(css, styleClass, themeScope)
                $(newStyleElement).text(narrowedCss)

                params = {}

                editors = []
                if themeScope == "file"
                  params.uri = fn || @utils.getActiveFile()
                  # get all the textEditors open for this file
                  editors = @utils.getTextEditors params
                else if themeScope == "fileType" && !fn
                  params.fileExt = fileExt
                  # get all the textEditors open for this file ext
                  editors = @utils.getTextEditors params
                else
                  editors.push ed || atom.workspace.getActiveTextEditor()

                for editor in editors
                  # We have to get a new styleElement each time i.e. we need to clone
                  # it.  If we create just one styleElement outside of this loop, it will simply get reassigned
                  # to the last editor we attach it too, and it won't be assigned to any of
                  # the previous editors
                  editorElem = editor.getElement();

                  # if the editor element already has the new styleClass applied, skip it.
                  # We only want to update new elements.  If we update already updated elements, then
                  # the new class can override lower styles that should be taking effect.
                  continue if $(editorElem).attr('class').match( new RegExp styleClass)
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
                styleClass = @localThemeManager.addStyleElementToHead(newStyleElement, 'pane', themeName)

                narrowedCss = @localThemeManager.narrowStyleScope(css, styleClass, "pane")
                $(newStyleElement).text(narrowedCss)

                pane = atom.workspace.getActivePane()
                paneElem = @localThemeManager.getActivePaneElem()

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

                windowElem = @localThemeManager.getActiveWindowElem()

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
                elemState['themePath'] = baseCssPath
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
