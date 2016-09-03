$ = jQuery = require 'jquery'
Utils = require './utils'
fs = require 'fs-plus'
path = require 'path'
less = require 'less'

module.exports =
  class LocalThemeManager

    constructor: ->
      @utils = new Utils()
      # #vt add
      # # atom.workspace.observePaneItems( () -> {
      # #   console.log 'LocalThemeManager.cb: detected paneItem change' 
      # # })      
      # console.log "LocalThemeManager.ctor: about to call observePaneItems"
      # atom.workspace.observePaneItems (item) -> 
      #   console.log "LocalThemeManager.cb: detected paneItem change, item=#{item}"  
      #   console.log "LocalThemeManager.cb: typeof item=#{typeof item}"  
        
      #   # if item instanceof atom.TextEditor.constructor
      #   if item.constructor.name is 'TextEditor'
      #     console.log "item is a TextEditor"
      #     console.log " and fn = #{item.buffer.file.path}"
      # #vt end

    doIt: ->
      getActivePackages = atom.packages.getActivePackages
      7

    # return the active theme as a string
    # Note: this is defunct with the per buffer replacment design
    getActiveSyntaxTheme: ->
      getActivePackages = atom.packages.getActivePackages
      activePackages = atom.packages.getActivePackages()

      activeTheme = ''

      for pkg in activePackages
        if pkg.metadata.theme == 'syntax'
            activeTheme = pkg.metadata.name

      activeTheme

    addStyleElementToEditor: (styleElement, editor)->
      shadowRoot

      if editor?
        shadowRoot = @utils.getShadowRoot editor
      else
        shadowRoot = @utils.getActiveShadowRoot()

      $shadowRoot = $(shadowRoot)
      themeNode = $shadowRoot
        .find('[context="atom-text-editor"]')
        .filter('atom-styles')
        .append(styleElement)

    deleteThemeStyleNode: (editor) ->
      shadowRoot

      if editor?
        shadowRoot = @utils.getShadowRoot editor
      else
        shadowRoot = @utils.getActiveShadowRoot()

      $shadowRoot = $(shadowRoot)
      themeNode = $shadowRoot
        .find('[context="atom-text-editor"]')
        .filter('atom-styles')
        .find('[priority="1"]')
        .filter('[source-path*="index.less"]')

      if (themeNode.length != 1)
        return -1

      themeNode.remove()

    getThemeCss: (basePath) ->
      lessPath = basePath + "/index.less"

      data = fs.readFileSync(lessPath, 'utf8')

      data = data.toString()

      options = {
        paths : [basePath, basePath + '/styles']
        filename : "index.less"
      }

      promise = new Promise (resolve, reject) ->
        less.render data, options, (err, result) ->
          if err
            reject err
          else
            resolve result.css.toString()

    syncEditorBackgroundColor: (editor) ->
      shadowRoot

      if editor?
        shadowRoot = @utils.getShadowRoot editor
      else
        shadowRoot = @utils.getActiveShadowRoot()

      # drill down to the background-color set by the local theme
      # This is a pretty convaluted way that was empirically determined.
      # There's probably a better way.
      localStyleNode = $(shadowRoot)
        .find('atom-styles')
        .find('style').last()

      try
        localBgColor = localStyleNode[0].sheet.rules[0].style.backgroundColor
      catch error
        console.log "localThemeManager.syncEditorBackgroundColor: caught error #{error}"

      # We need to make sure we alter the style of the element of the javascript
      # object, not the style attribute in the Javascript object itself.  Altering
      # the style of the javascript object works in some cases, but leads to
      # trouble when you globally apply a new theme, or refresh (ctlr-alt-r) the
      # editor.
      $($(editor)[0].element).attr('style', 'background-color: ' + localBgColor)

    getSyntaxThemeLookup: () ->
      syntaxThemeLookup = []

      packageMetadata = atom.packages.getAvailablePackageMetadata()
      packagePaths = atom.packages.getAvailablePackagePaths()

      i = 0
      while i < packageMetadata.length
        pm = packageMetadata[i]
        if pm.theme? && pm.theme == 'syntax'
          syntaxThemeLookup.push {themeName: pm.name, baseDir: packagePaths[i]}
        i++

      syntaxThemeLookup

    #vt add
    # this method sets up a listener for pane events that insert new
    # TextEditors.  For example, if someone invokes a
    # 'pane:split-right-and-copy-active-item' command and causes a new instance
    # of a locally themed editor, we want to proactively apply the local theme
    # to the associalted files editor automtically, without the user having to
    # do it manually.  If the event is of the right type, we call the supply
    # callback function in the handlerObj to apply the theme to new TextEditor.
    # Note: we have to pass the whole instance object that contains
    # 'applyLocalThem' because we need the entire object context (passing just
    # the method wil fail)
    # initPaneEventHandler: (applyTheme_cb) ->
    initPaneEventHandler: (handlerObj) ->
      #vt add
      console.log "LocalThemeManager.initPaneEventHandler: about to call observePaneItems"
      atom.workspace.observePaneItems (item) -> 
        console.log "LocalThemeManager.cb: detected paneItem change, item=#{item}"  
        console.log "LocalThemeManager.cb: typeof item=#{typeof item}"  
        
        # apply local theme if item instanceof atom.TextEditor.constructor
        if item.constructor.name is 'TextEditor'
          fn = item.buffer.file.path
          console.log "item is a TextEditor"
          console.log " and fn = #{fn}"
          # if fn.match(/dummy2/)
          localThemePath = handlerObj.fileLookup[fn]
          if localThemePath
            console.log "now calling applyLocalTheme to apply theme #{localThemePath}"
            # applyTheme_cb('C:\Users\vturner\.atom\packages\choco')
            # applyTheme_cb('C:/Users/vturner/.atom/packages/choco')
            # handlerObj.applyLocalTheme('C:/Users/vturner/.atom/packages/choco')
            handlerObj.applyLocalTheme(localThemePath)
      #vt end
    #vt end