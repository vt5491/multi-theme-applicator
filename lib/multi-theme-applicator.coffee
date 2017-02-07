$ = jQuery = require 'jquery'
Base = require './base'
Utils  = require './utils'

LocalThemeSelectorView = require './local-theme-selector-view'
{CompositeDisposable} = require 'atom'
module.exports = MultiThemeApplicator =
  localThemeSelectorView: LocalThemeSelectorView
  themeSelectorPanel: null
  subscriptions: null

  activate: (state) ->
    console.log "MultiThemeApplicator.activiate: entered"
    @utils = new Utils()
    # @localThemeSelectorView = new LocalThemeSelectorView(this, state)
    @localThemeSelectorView = new LocalThemeSelectorView(
      this, state['fileLookup'], state['FileTypeLookup'], state['ThemeLookup'])
    #vt add
    # reapply any 'fileType' scope themes
    # if state['FileTypeLookup'] && Object.keys(state['FileTypeLookup']).length > 0
    #   console.log 'hi'
    #   for fileType in Object.keys state['FileTypeLookup']
    #     themePath = state['FileTypeLookup'][fileType]
    #     for editor in atom.workspace.getTextEditors()
    #       editorFile = @utils.getActiveFile editor
    #       fileExt = @utils.getFileExt editorFile
    #
    #       if fileExt == fileType
    #         @localThemeSelectorView.applyLocalTheme editorFile, themePath, 'fileType'


    # if state['ElementLookup'] && state['ElementLookup'] instanceof WeakMap
    #   Base.ElementLookup = state['ElementLookup']
    #
    # # reapply any previous window level theme
    # windowElem = $('atom-pane-container.panes')[0]
    # if windowInfo = Base.ElementLookup.get windowElem
    #   themePath = windowInfo['themePath']
    #   @localThemeSelectorView.applyLocalTheme '', themePath, 'window'
    # reapply any fileType themes
    #vt end
    # atom.deserializers.deserialize(state)
    # @localThemeSelectorView = new LocalThemeSelectorView(this, state['fileLookup'])

    @localThemeSelectorPanel = atom.workspace.addModalPanel(
      item: @localThemeSelectorView.getElement(),
      visible: false
    )

    @subscriptions = new CompositeDisposable

    # Register the commands we want to appear in the palette.  These will only
    # show once MTA has been initialized e.g. after you've done a shift-ctrl-v
    # to bring up the theme dropdown.
    cmdObj = {
      'multi-theme-applicator:toggle': => @toggle(),
      'multi-theme-applicator:reset': => @reset(),
      'multi-theme-applicator:refresh-theme-info': => @refreshThemeInfo()
    }

    @subscriptions.add atom.commands.add('atom-workspace', cmdObj)

    #vt add
    @utils = new Utils()
    # atom.commands.add 'multi-theme-applicator',
    #   'refresh-theme-info': (event) =>
    #     @localThemeSelectorView.refreshThemeInfo()

    #vt end

  deactivate: () ->
    @subscriptions.dispose()
    @localThemeSelectorView.destroy()
    @localThemeSelectorPanel.destroy()

  serialize: () ->
    # state
    state = {}

    if(@localThemeSelectorView && @localThemeSelectorView.fileLookup)
      # state = @localThemeSelectorView.fileLookup
      state['fileLookup'] = @localThemeSelectorView.fileLookup

    state['FileTypeLookup'] = Base.FileTypeLookup
    state['ThemeLookup'] = Base.ThemeLookup
    # state['ElementLookup'] = Base.ElementLookup

    state
    # state.serialize()

  doIt: () ->
    7

  toggle: () ->
    if @localThemeSelectorPanel.isVisible()
      @localThemeSelectorPanel.hide()
      if atom.workspace.getActiveTextEditor()
        atom.workspace.getActiveTextEditor().getElement().focus()
    else
      @localThemeSelectorPanel.show()
      # and give the dropdown keyboard focus
      @localThemeSelectorView.focusModalPanel()

  reset: () ->
    console.log "MultiThemeApplicator.reset: entered"
    for editor in atom.workspace.getTextEditors()
      if editorInfo = Base.ElementLookup.get editor
        if editorInfo['file']
          @localThemeSelectorView.localThemeManager.removeScopedTheme 'file', editor
          # styleClass = editorInfo['file']['styleClass']
          # # if styleClass
          # @localThemeSelectorView.localThemeManager.removeStyleElementFromHead(styleClass)
        if editorInfo['fileType']
          @localThemeSelectorView.localThemeManager.removeScopedTheme 'fileType', editor
          # styleClass = editorInfo['file']['styleClass']
          # # if styleClass
          # @localThemeSelectorView.localThemeManager.removeStyleElementFromHead(styleClass)
    for pane in atom.workspace.getPanes()
      if paneInfo = Base.ElementLookup.get pane
        @localThemeSelectorView.localThemeManager.removeScopedTheme 'pane', pane

    windowElem = $('atom-pane-container.panes')[0]
    if Base.ElementLookup.get windowElem
      @localThemeSelectorView.localThemeManager.removeScopedTheme 'window', windowElem


        # styleClass = editorInfo[]['styleClass']
        # remove any file level styles
        # if editorInfo['file']
        #   styleClass = editorInfo['file']['styleClass']
        #   if styleClass
        #     $(editor.getElement()).removeClass(styleClass)
        #     @localThemeSelectorView.localThemeManager.removeStyleElementFromHead(styleClass)
        # # and remove any fileType styles
        # if editorInfo['fileType']
        #   styleClass = editorInfo['fileType']['styleClass']
        #   if styleClass
        #     $(editor.getElement()).removeClass(styleClass)
        #     @localThemeSelectorView.localThemeManager.removeStyleElementFromHead(styleClass)

    @localThemeSelectorView.fileLookup = {}
    Base.FileTypeLookup = {}
    # Base.ElementLookup = new WeakMap()
    # @utils.resetPanes()
    #vt add
    # activePane = atom.workspace.getActivePane()
    # activeItemIndex = activePane.getActiveItemIndex()
    # activePane.activateItemAtIndex(activeItemIndex)

    #vt end


  #vt add
  refreshThemeInfo: () ->
    @localThemeSelectorView.refreshThemeInfo()
  #vt end
