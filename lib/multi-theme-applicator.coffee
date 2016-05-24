$ = jQuery = require 'jquery'

LocalThemeSelectorView = require './local-theme-selector-view'
{CompositeDisposable} = require 'atom'

# module.exports = MultiThemeApplicatorView =
module.exports = MultiThemeApplicator =
  #@localThemeSelectorView = new themeSelectorView ();
  localThemeSelectorView: LocalThemeSelectorView
  themeSelectorPanel: null
  #themeSelectorPanel
  #modalPanel: null
  subscriptions: null
  #themeSelector: null
  #themeSelectorView: null
  #themeSelector: null

  activate: (state) ->
    # @themeSelector = new themeSelector(state.themeSelectorState)
    #@themeSelector = new themeSelector
    #@themeSelectorView = new ThemeSelectorView(state.ThemeSelectorViewState);
    @localThemeSelectorView = new LocalThemeSelectorView(this)

    # @modalPanel = atom.workspace.addModalPanel(
    #   item: @themeSelectorView.getElement(),
    #   visible: false
    # )

    @localThemeSelectorPanel = atom.workspace.addModalPanel(
      item: @localThemeSelectorView.getElement(),
      visible: false
    )

    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'multi-theme-applicator:toggle':  => @toggle()

  deactivate: () ->
    #@modalPanel.destroy()
    @subscriptions.dispose()
    @localThemeSelectorView.destroy()
    @localThemeSelectorPanel.destroy()

  doIt: () ->
    7

  toggle: () ->
    console.log('MultiThemeApplicator.toggle: now in toggle');

    if @localThemeSelectorPanel.isVisible()
      #@modalPanel.hide()
      @localThemeSelectorPanel.hide()
    else
      #@modalPanel.show()
      @localThemeSelectorPanel.show()
  # serialize: () ->
  #   vtAtomPkgTestViewState: @vtAtomPkgTestView.serialize()
