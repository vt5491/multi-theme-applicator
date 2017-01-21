$ = jQuery = require 'jquery'

LocalThemeSelectorView = require './local-theme-selector-view'
{CompositeDisposable} = require 'atom'
module.exports = MultiThemeApplicator =
  localThemeSelectorView: LocalThemeSelectorView
  themeSelectorPanel: null
  subscriptions: null

  activate: (state) ->
    console.log "MultiThemeApplicator.activiate: entered3"
    @localThemeSelectorView = new LocalThemeSelectorView(this, state)

    # console.log `MultiThemeApplicator.activiate: LocalThemeSelectorView=${@localThemeSelectorView}`
    console.log 'MultiThemeApplicator.activiate: LocalThemeSelectorView=' + @localThemeSelectorView
    @localThemeSelectorPanel = atom.workspace.addModalPanel(
      item: @localThemeSelectorView.getElement(),
      visible: false
    )

    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    cmdObj = {
      'multi-theme-applicator:toggle': => @toggle(),
      'multi-theme-applicator:reset': => @reset()
    }

    @subscriptions.add atom.commands.add('atom-workspace', cmdObj)

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
