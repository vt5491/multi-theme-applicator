$ = jQuery = require 'jquery'

LocalThemeSelectorView = require './local-theme-selector-view'
{CompositeDisposable} = require 'atom'

module.exports = MultiThemeApplicator =
  localThemeSelectorView: LocalThemeSelectorView
  themeSelectorPanel: null
  subscriptions: null

  activate: (state) ->
    console.log('vt:MultiThemeApplicator.activate: entered')
    # state = {}
    if(state)
      console.log("vt:MultiThemeApplicator.activate: state=#{JSON.stringify(state)}")

    #@localThemeSelectorView = new LocalThemeSelectorView(this)
    @localThemeSelectorView = new LocalThemeSelectorView(this, state)
    #vt add
    # refreshAllLocalThemes is not necessary, plus it doesn't fix the
    # bug where one of the editors is not themed properly upon editor
    # restart.
    # @localThemeSelectorView.refreshAllLocalThemes()
    # console.log("vt:MultiThemeApplicator.activate: fileLookup=" + 
    # JSON.stringify(@localThemeSelectorView.fileLookup))
    # fn = 'C:/vtstuff/tmp/dummy.js'
    # console.log("vt:MultiThemeApplicator.activate: state['C:/vtstuff/tmp/dummy.js']=#{state['C:/vtstuff/tmp/dummy.js']}")
    # localThemePath = @localThemeSelectorView.fileLookup[fn]
    # if localThemePath
    #   console.log("vt:MultiThemeApplicator.activate: now applying #{localThemePath}")
    #   @localThemeSelectorView.applyLocalTheme(fn, localThemePath)

    #   fn = 'C:/vtstuff/tmp/dummy2.js'
    #   localThemePath = @localThemeSelectorView.fileLookup[fn]
    #   if localThemePath
    #     console.log("vt:MultiThemeApplicator.activate: now applying #{localThemePath}")
    #     @localThemeSelectorView.applyLocalTheme(fn, localThemePath)
    #vt end


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

    # console.log('vt:MultiThemeApplicator: atom.commands.atom-workspace=' +
    #   atom.commands.findCommands('atom-workspace').length)

    #   # ,
    #   # 'atom-workspace',
    #   # 'multi-theme-applicator:reset':  => @reset()
    #vt add
    # Register command that resets the fileLookup table
    # @subscriptions.add atom.commands.add 'atom-workspace',
    #   'multi-theme-applicator:reset':  => @reset()
    #vt end



  deactivate: () ->
    @subscriptions.dispose()
    @localThemeSelectorView.destroy()
    @localThemeSelectorPanel.destroy()

  #vt add
  serialize: () ->
    state

    if(@localThemeSelectorView && @localThemeSelectorView.fileLookup)
      # state = @localThemeSelectorView.fileLookup.serialize()
      # state = JSON.stringify(@localThemeSelectorView.fileLookup)
      state = @localThemeSelectorView.fileLookup

    console.log("vt:multi.serialize: fileLookup.serialize=#{JSON.stringify(state)}")

    # if (state)
    #   # save the fileLookup as .json, so that when we restart we can
    #   # restore the last file level theming "schema" 
    #   console.log('vt: serialze: now saving state')
    #   @localThemeSelectorView.fileLookup.serialize()
    state
  #vt end

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

  #vt add
  reset: () ->
    console.log('vt: now resetting fileLookup')
    @localThemeSelectorView.fileLookup = {}
  #vt end
