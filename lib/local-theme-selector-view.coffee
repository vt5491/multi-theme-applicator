$ = jQuery = require 'jquery'
Utils = require './utils'
LocalThemeManager = require './local-theme-manager'
LocalStylesElement  = require './local-styles-element'
fs = require('fs-plus')
async = require('async')

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
#       var s = $("<select id=\"selectId\" name=\"selectName\" />");
# for(var val in data) {
#     $("<option />", {value: val, text: data[val]}).appendTo(s);
# }
      # @themeLookup = []
      # packageBaseDir = '/home/vturner/.atom/packages/'
      # @themeLookup.push {themeName: 'choco', baseDir: "#{packageBaseDir}/choco" }
      # @themeLookup.push {themeName: 'humane-syntax', baseDir: "#{packageBaseDir}/humane-syntax" }
      # @themeLookup.push {themeName: 'seti-syntax', baseDir: "#{packageBaseDir}/seti-syntax" }

      themeDropdown = $('<select id="themeDropdown" name="selectTheme">')

      #for i in LocalThemeSelectorView::ThemeLookup
      for theme in LocalThemeSelectorView::ThemeLookup
      #for i in this.ThemeLookup
        # console.log "i=#{i}"
        # console.log "baseDir=#{LocalThemeSelectorView::ThemeLookup[i].baseDir}"
        $('<option>', {
          # value: LocalThemeSelectorView::ThemeLookup[i].baseDir,
          # text: LocalThemeSelectorView::ThemeLookup[i].themeName})
          value: theme.baseDir,
          text: theme.themeName})
        .appendTo(themeDropdown)

      themeDropdown.appendTo(form)

    # Come here on submit
    applyLocalTheme: ->
      console.log('ThemeSelector.applyLocalTheme: entered 2')
      #$( "#myselect" ).val();
      # $( "#themeDropdown" ).val();
      # css = ''
      # @localThemeManager.getThemeCss().then (result) =>
      #   css = result
      # , (err) ->
      #   console.log "promise returned with err=" + err
      # sourcePath = '/home/vturner/.atom/packages/humane-syntax/index.less'
      #sourcePath = '/home/vturner/.atom/packages/humane-syntax/index.less'
      #sourcePath = '/home/vturner/.atom/packages/choco/index.less'
      #css = @utils.getHumaneCssString()
      # css = fs.readFileSync(sourcePath, 'utf8')
      #baseCssPath = '/home/vturner/.atom/packages/choco'
      # baseCssPath = '/home/vturner/.atom/packages/humane-syntax'
      baseCssPath = $( "#themeDropdown" ).val();
      console.log("applyLocalTheme: baseCssPath=#{baseCssPath}")
      sourcePath = baseCssPath + '/index.less'

      promise = @localThemeManager.getThemeCss baseCssPath

      cssResult = null

      # try
      #   async.waterfall [
      #     () =>
      #       promise = @localThemeManager.getThemeCss baseCssPath
      #       promise
      #       .then(
      #         (result) ->
      #           console.log "->promise return: css=" + result.substring(0,200)
      #           cssResult = result
      #         ,(err) ->
      #             console.log "promise returner err" + err
      #       )
      #     ,
      #     () =>
      #       console.log "cssResult-2=" + cssResult.substring(0,200),
      #     () =>
      #       newStyleElement = @localStylesElement.createStyleElement(css, sourcePath)
      #       # TODO: change name of method to indicate more clearly it *is* the active editor
      #       @localThemeManager.deleteThemeStyleNode()
      #       @localThemeManager.addStyleElementToEditor(newStyleElement)
      #       @localThemeManager.syncEditorBackgroundColor()
      #   ]
      # catch err
      #   console.log "async.waterfall error: #{err}"

      # promise
      #   .then(
      #     (result) ->
      #       console.log "->promise return: css=" + result.substring(0,200)
      #       cssResult = result
      #     ,(err) ->
      #       console.log "promise returner err" + err
      #   )
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

      # #console.log "cssResult-2=" + cssResult.substring(0,200)
      # # LSE.createStyleElement
      # # p.s. the sourcePath is just important for cosmetic reasons.  It could
      # # actualy be anything
      # newStyleElement = @localStylesElement.createStyleElement(css, sourcePath)
      # # LTM.deleteThemeStyleNode
      # # This goes against the active editor
      # # TODO: change name of method to indicate more clearly it *is* the active editor
      # @localThemeManager.deleteThemeStyleNode()
      # # LTM.addStyleElementToEditor
      # @localThemeManager.addStyleElementToEditor(newStyleElement)
      # # LTM.syncEditorBackgroundColor
      # @localThemeManager.syncEditorBackgroundColor()

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
