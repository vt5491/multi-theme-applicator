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

    addStyleElementToEditor: (styleElement, editor)->
      console.log "LocalThemeManager.addStyleElementToEditor: entered"
      editorElement

      if editor?
        # editorElement = @utils.geteditorElement editor
        editorElement = @utils.getEditorElement editor
      else
        editorElement = @utils.getActiveEditorElement()

      $editorElement = $(editorElement)
      # create the atom-styles element if it doesn't exist

      if !$editorElement.find('atom-styles').length
        $editorElement.append($('<atom-styles context="atom-text-editor"></atom-styles>'))
      # add "priority=1" attribute to the styleElement
      # TODO: also add context=atom-text-editor to the style element
      # only the style element has the priority=1 though
      $(styleElement).attr("priority", "1");

      themeNode = $editorElement
        .find('[context="atom-text-editor"]')
        .filter('atom-styles')
        .append(styleElement)
      # themeName = $editorElement.parent().append(styleElement)

    addStyleElementToHead: (styleElement, editor)->
      # document.getElementsByTagName('head')[0]
      #   .appendChild(styleElement)
      styleClass = 'mta-editor-style-' + Date.now()
      $(styleElement).addClass(styleClass)
      $('head').find('atom-styles').append(styleElement)

      # return styleKey to the user
      styleClass
    
    removeStyleElementFromHead: (styleClass) ->
      # $.find('head atom-styles style.vt')[0].remove()
      if $.find("head atom-styles style.#{styleClass}").length > 0 
        $.find("head atom-styles style.#{styleClass}")[0].remove()
      
    deleteThemeStyleNode: (editor) ->
      editorElement

      if editor?
        editorElement = @utils.getEditorElement editor
      else
        editorElement = @utils.getActiveEditorElement()

      $editorElement = $(editorElement)
      themeNode = $editorElement
        .find('[context="atom-text-editor"]')
        .filter('atom-styles')
        .find('[priority="1"]')
        .filter('[source-path*="index.less"]')

      if (themeNode.length != 1)
        return -1

      themeNode.remove()
    
    # remove the "mta style" class from the given dom element.  The element will
    # be an editor, pane, or "window" html element.
    removeStyleClassFromElement: (element) ->
      elemClass = element.getAttribute('class')
      # console.log "ut: element=#{elemClass}"

      # tmp = elemClass.replace(/\s?mta-\w+-style-\d{10,}/, '')
      # console.log "ut: tmp=#{tmp}"
      # typical mta style class: mta-editor-style-1484974763214
      # element.setAttribute('class', elemClass.replace(\s?/mta-\w+-style-\d{10,}/, ''))
      # since we should have inserted one leading padding space and some text, we remove
      # one leading space (or zero, if it's the beginning of the line) and some text
      if elemClass
        element.setAttribute('class', elemClass.replace(/\s?mta-\w+-style-\d{10,}/, ''))

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
      editorElement

      if editor?
        editorElement = @utils.getEditorElement editor
      else
        editorElement = @utils.getActiveEditorElement()

      # drill down to the background-color set by the local theme
      # This is a pretty convaluted way that was empirically determined.
      # There's probably a better way.
      localStyleNode = $(editorElement)
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
          #vtsyntaxThemeLookup.push {themeName: pm.name, baseDir: packagePaths[i]}
          syntaxThemeLookup.push {themeName: pm.name, baseDir: packagePaths[i].replace(/\\/g, '/')}
        i++

      syntaxThemeLookup

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
    # Note: in our case, the handlerObj is an instance of 'LocalThemeManagerSelectorView'
    initPaneEventHandler: (handlerObj) ->
      atom.workspace.observePaneItems (item) ->

        # apply local theme if item instanceof atom.TextEditor.constructor
        if item.constructor.name is 'TextEditor'
          if item.buffer.file
            fn = item.buffer.file.path.replace(/\\/g, '/')
            localThemePath = handlerObj.fileLookup[fn]
            if localThemePath
              handlerObj.applyLocalTheme(fn, localThemePath)

# atom-text-editor,
# :host {
#   background-color: #212020;
#   color: #fff0ed;
# }
    # parse the css and decorate with the styleKey in the selectors to narrow
    # the scope in which this style sheet applies.  For incstance, if we are
    # adding a style at the editor level, the editor element class will have
    # a unique styleKey added to it.  We then need to add this class to the css
    # selector, so the style is applied to only that one editor 
    narrowStyleScope: (css, styleClass) ->
      # console.log "narrowStyleScope.css=#{css}"
      # narrowedCss = css

      # narrowedCss = css.replace(/^(.*,$)/gm, ".#{styleClass} $1")
      narrowedCss = css.replace(/^(.*),$/gm, "$1." + styleClass + ",")
      # narrowedCss = narrowedCss.replace(/^(.*\{$)/gm, ".#{styleClass} $1")
      narrowedCss = narrowedCss.replace(/^(.*) \{$/gm, "$1." + styleClass + " {")

      narrowedCss

