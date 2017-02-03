$ = jQuery = require 'jquery'

LocalThemeSelectorView = require './local-theme-selector-view'
{CompositeDisposable} = require 'atom'
module.exports = MultiThemeApplicator =
  localThemeSelectorView: LocalThemeSelectorView
  themeSelectorPanel: null
  subscriptions: null

  activate: (state) ->
    console.log "MultiThemeApplicator.activiate: entered"
    @localThemeSelectorView = new LocalThemeSelectorView(this, state)

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
    # atom.commands.add 'multi-theme-applicator',
    #   'refresh-theme-info': (event) =>
    #     @localThemeSelectorView.refreshThemeInfo()

    #vt end

  deactivate: () ->
    @subscriptions.dispose()
    @localThemeSelectorView.destroy()
    @localThemeSelectorPanel.destroy()

  serialize: () ->
    state

    if(@localThemeSelectorView && @localThemeSelectorView.fileLookup)
      state = @localThemeSelectorView.fileLookup

    state

  doIt: () ->
    7

  toggle: () ->
    if @localThemeSelectorPanel.isVisible()
      @localThemeSelectorPanel.hide()
      atom.workspace.getActiveTextEditor().getElement().focus()
    else
      @localThemeSelectorPanel.show()
      # and give the dropdown keyboard focus
      @localThemeSelectorView.focusModalPanel()

  reset: () ->
    @localThemeSelectorView.fileLookup = {}

  #vt add
  refreshThemeInfo: () ->
    @localThemeSelectorView.refreshThemeInfo()
  #vt end
