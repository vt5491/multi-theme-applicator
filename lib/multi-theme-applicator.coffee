$ = jQuery = require 'jquery'
Base = require './base'
Utils  = require './utils'
LocalThemeManager = require './local-theme-manager'

LocalThemeSelectorView = require './local-theme-selector-view'
{CompositeDisposable} = require 'atom'
module.exports = MultiThemeApplicator =
  localThemeSelectorView: LocalThemeSelectorView
  themeSelectorPanel: null
  subscriptions: null

  activate: (state) ->
    console.log "MultiThemeApplicator.activiate: entered v1.3.2"
    @utils = new Utils()
    @localThemeManager = new LocalThemeManager()
    @localThemeSelectorView = new LocalThemeSelectorView(
      this, state['fileLookup'], state['FileTypeLookup'], state['ThemeLookup'])

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

    @utils = new Utils()

  deactivate: () ->
    @subscriptions.dispose()
    @localThemeSelectorView.destroy()
    @localThemeSelectorPanel.destroy()

  serialize: () ->
    state = {}

    if(@localThemeSelectorView && @localThemeSelectorView.fileLookup)
      state['fileLookup'] = @localThemeSelectorView.fileLookup

    state['FileTypeLookup'] = Base.FileTypeLookup
    state['ThemeLookup'] = Base.ThemeLookup

    state

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
    for editor in atom.workspace.getTextEditors()
      if editorInfo = Base.ElementLookup.get editor
        if editorInfo['editor']
          @localThemeSelectorView.localThemeManager.removeScopedTheme 'editor', editor
        if editorInfo['file']
          @localThemeSelectorView.localThemeManager.removeScopedTheme 'file', editor
        if editorInfo['fileType']
          @localThemeSelectorView.localThemeManager.removeScopedTheme 'fileType', editor
    for pane in atom.workspace.getPanes()
      if paneInfo = Base.ElementLookup.get pane
        @localThemeSelectorView.localThemeManager.removeScopedTheme 'pane', pane

    windowElem = @localThemeManager.getActiveWindowElem()
    if Base.ElementLookup.get windowElem
      @localThemeSelectorView.localThemeManager.removeScopedTheme 'window', windowElem


    @localThemeSelectorView.fileLookup = {}
    Base.FileTypeLookup = {}
    # Note: be careful about clearing out the ElementLookup WeakMap.  There seems
    # to be issue if you clear this out without also doing a shitf-ctrl-f5 resetPanes
    # or cycling atom (in other words resetting with one atom session)
    # Base.ElementLookup = new WeakMap()

  refreshThemeInfo: () ->
    @localThemeSelectorView.refreshThemeInfo()
