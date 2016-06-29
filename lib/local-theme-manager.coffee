$ = jQuery = require 'jquery'
Utils = require './utils'
fs = require 'fs-plus'
path = require 'path'
less = require 'less'

module.exports =
  class LocalThemeManager

    constructor: ->
      @utils = new Utils()

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

    #vtaddStyleElementToEditor: (styleElement)->
    addStyleElementToEditor: (styleElement, editor)->
      #vtshadowRoot = @utils.getActiveShadowRoot()
      #vt add
      shadowRoot

      if editor?
        shadowRoot = @utils.getShadowRoot editor
        console.log("@@@localThemeManager.addStyleElementToEditor: driving new path")
      else
        shadowRoot = @utils.getActiveShadowRoot()
      #vt end
      $shadowRoot = $(shadowRoot)
      themeNode = $shadowRoot
        .find('[context="atom-text-editor"]')
        .filter('atom-styles')
        .append(styleElement)

    #vtdeleteThemeStyleNode: ->
    deleteThemeStyleNode: (editor) ->
      #vtshadowRoot = @utils.getActiveShadowRoot()
      #vt add
      shadowRoot

      if editor?
        shadowRoot = @utils.getShadowRoot editor
        console.log("@@@localThemeManager: driving new path")
      else
        shadowRoot = @utils.getActiveShadowRoot()
      #vt end
      $shadowRoot = $(shadowRoot)
      themeNode = $shadowRoot
        .find('[context="atom-text-editor"]')
        .filter('atom-styles')
        .find('[priority="1"]')
        .filter('[source-path*="index.less"]')

      if (themeNode.length != 1)
        console.log("LocalThemeManager.deleteThemeNode: could not properly identify the theme node")
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

    #vtsyncEditorBackgroundColor: () ->
    syncEditorBackgroundColor: (editor) ->
      #vtshadowRoot = @utils.getActiveShadowRoot()
      #vt add
      shadowRoot

      if editor?
        shadowRoot = @utils.getShadowRoot editor
        console.log("@@@localThemeManager.syncEditorBackgroundColor: driving new path")
      else
        shadowRoot = @utils.getActiveShadowRoot()
      #vt end

      # drill down to the background-color set by the local theme
      # This is a pretty convaluted way that was empirically determined.
      # There's probably a better way.
      localStyleNode = $(shadowRoot)
        .find('atom-styles')
        .find('style').last()

      #vt add
      try
      #vt end
        localBgColor = localStyleNode[0].sheet.rules[0].style.backgroundColor
      #vt add
      catch error
        console.log "localThemeManager.syncEditorBackgroundColor: caught error #{error}"
      #vt end

      #vtactiveTextEditor = atom.workspace.getActiveTextEditor()
      # We need to make sure we alter the style of the element of the javascript
      # object, not the styl attribute in the Javascript object itself.  Altering
      # the style of the javascript object works in some cases, but leads to
      # trouble when you globally apply a new theme, or refresh (ctlr-alt-r) the
      # editor.
      #$(activeTextEditor).attr('style', 'background-color: ' + localBgColor)
      #vt$($(activeTextEditor)[0].element).attr('style', 'background-color: ' + localBgColor)
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
