$ = jQuery = require 'jquery'
Utils = require './utils'
fs = require 'fs-plus'
path = require 'path'
less = require 'less'
Base = require './base'

module.exports =
  class LocalThemeManager

    constructor: ->
      #vtconsole.log "LocalThemeManager.ctor: entered"
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

    # add style to head.  If a previous entry of the same type is found, then
    # do not add to head, and return the prior styleClass instead.
    addStyleElementToHead: (styleElement, scope, themeName )->
      styleClassStem = "mta-#{scope}-#{themeName}-style-"
      prevStyle = $('head').find('atom-styles style')
        .filter () ->
          this.className.match(new RegExp styleClassStem)

      styleClass
      if prevStyle[0]
        # note timestamps are typically 13 digits, but we'll use 10 or greater as a proxy
        # since, in the future, it could be > 13 digits and we don't want to lock in on 13.
        re = new RegExp "(#{styleClassStem}\\d{10,})"
        styleClass = prevStyle.attr('class').match(re)[1]
      else
        styleClass = "mta-#{scope}-#{themeName}-style-" + Date.now()
        $('head').find('atom-styles').append(styleElement)
        $(styleElement).addClass(styleClass)

      # return styleKey to the user
      styleClass

    removeStyleElementFromHead: (styleClass) ->
      if $.find("head atom-styles style.#{styleClass}").length > 0
        $.find("head atom-styles style.#{styleClass}")[0].remove()

    # Remove the scoped theme from the active scope, or the passed artifact (editor, pane , or window element).
    # This involves deleting the css
    # from head->atom-styles as well as removing the class tag from any elements
    # tagged in the scope (for example, "file" scope will include multiper editor elements)
    # removeScopedTheme: (scope) ->
    removeScopedTheme: (scope, artifact) ->
      switch scope
        when "fileType", "file", "editor"
          editor = artifact || atom.workspace.getActiveTextEditor()
          editorElem = editor.getElement()
          # get the class associated with this element
          styleClass
          if Base.ElementLookup.get(editor) && Base.ElementLookup.get(editor)[scope]
            styleClass = Base.ElementLookup.get(editor)[scope]['styleClass']
          else
            # This is a "should not happen" condition, but empirically it was determined that
            # sometimes a themed editor is not appearing in ElementLookup.  Until I can figure
            # out the root cause, this will at least alllow us to clean up and not gen a stack trace.
            console.log "LocalThemeManager.removeScopedTheme: unable to find styleClass in ElementLookup"
            match = $(editorElem).attr('class').match(new RegExp("mta-#{scope}-.*-\\d{10,}"))
            styleClass = match[0] if match
            console.log "LocalThemeManager.removeScopedTheme: extracted styleClass=#{styleClass} from editor element"

          # remove from head
          if styleClass
            this.removeStyleElementFromHead(styleClass)

          editors = []

          if scope == "file"
            # editors = @utils.getTextEditors {uri : @utils.getActiveFile()}
            uri = @utils.normalizePath editor.getPath()
            editors = @utils.getTextEditors {uri : uri}
          else if scope == "fileType"
            fileExt = @utils.getFileExt(editor.getPath())
            editors = @utils.getTextEditors {fileExt : fileExt}
          else
            editors.push editor

          for editor in editors
            # and remove from the element itself
            editorElem = editor.getElement()

            $(editorElem).removeClass(styleClass)

            # delete the subkey
            if Base.ElementLookup.get(editor)
              delete Base.ElementLookup.get(editor)[scope]

              # if we've cleared out all subkeys, then delete the whole thing
              if Object.keys( Base.ElementLookup.get editor ).length == 0
                Base.ElementLookup.delete(editor)

        when "pane"
          pane = artifact || atom.workspace.getActivePane()
          $activePane = $('atom-pane.active')
          paneElem = this.getActivePaneElem()

          if Base.ElementLookup.get(pane)
            styleClass = Base.ElementLookup.get(pane)['styleClass']

          # remove from head
          if styleClass
            this.removeStyleElementFromHead(styleClass)

          $(paneElem).removeClass(styleClass)

          # remove from ElementLookup
          Base.ElementLookup.delete(pane)

        when "window"
          windowElem = this.getActiveWindowElem()

          if Base.ElementLookup.get(windowElem)
            styleClass = Base.ElementLookup.get(windowElem)['styleClass']

          # remove from head
          if styleClass
            this.removeStyleElementFromHead(styleClass)

          $(windowElem).removeClass(styleClass)

    getThemeCss: (basePath) ->
      statsPromise = new Promise (resolve, reject) ->
        fs.stat basePath, (err, stats) ->
          if err
            console.log "LocalThemeManager.getThemeCss: error #{err} loading path #{basePath}"
            reject err
            return

          # proceed to here if basePath exists
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

          # wait until render finishes
          promise.then (result) ->
            # resolve statsPromise once file has been read (rendered)
            resolve result

      statsPromise

    # parse the rendered less css text to determine the 'atom-text-editor'
    # background-color
    getCssBgColor: (css) ->
      # we just take the first background-color find and assume it the bg color
      # for the entire editor.  It just too hard to parse in the most general case.
      regExp = /(.*background-color:\s*)(#[0-9a-fA-F]{6})/m
      match = regExp.exec css

      if match
        match[2]
      else
        null


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
          syntaxThemeLookup.push {themeName: pm.name, baseDir: packagePaths[i].replace(/\\/g, '/')}
        i++

      syntaxThemeLookup

    getThemeDropdownHtml: (themeLookup) ->
      themeLookup.sort (a,b) ->
        nameA=a.themeName.toLowerCase()
        nameB=b.themeName.toLowerCase()
        if nameA < nameB
          return -1
        if nameA > nameB
          return 1
        return 0

      html = ''

      for theme in themeLookup
        html += $('<option>', {
          value: theme.baseDir,
          text: theme.themeName})
        .prop('outerHTML')

      html


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
            fileExt = handlerObj.utils.getFileExt(fn)
            fileExtThemePath = Base.FileTypeLookup[fileExt]
            # apply any fileType theme, then any file level.  If both are active, then
            # by applying the file type last, it will take precedence.  We have to
            # apply both in order to make remove work properly in the most general cases.
            #console.log "vt:localThemeManager.observePaneItems: fn=#{fn}, localThemePath=#{localThemePath}, fileExtThemePath=#{fileExtThemePath}"
            #debugger
            if fileExtThemePath
              #vthandlerObj.applyLocalTheme(fn, fileExtThemePath, 'fileType')
              handlerObj.applyLocalTheme fn, fileExtThemePath, 'fileType', item
            if localThemePath
              #vthandlerObj.applyLocalTheme(fn, localThemePath, 'file')
              handlerObj.applyLocalTheme fn, localThemePath, 'file', item

    initOnDidDestroyPaneHandler: () ->
      atom.workspace.onDidDestroyPane (event) =>
        pane = event.pane

        if Base.ElementLookup.get(pane)
          styleClass = Base.ElementLookup.get(pane)['styleClass']

        # remove from head
        if styleClass
          this.removeStyleElementFromHead(styleClass)

        # remove from ElementLookup
        Base.ElementLookup.delete(pane)

    initOnDidDestroyPaneItem: () ->
      atom.workspace.onDidDestroyPaneItem (event) =>

        # return if !(event.item instanceof "TextEditor")
        return if (event.item.constructor.name != "TextEditor")

        editor = event.item

        editorStyleClass = ''
        if Base.ElementLookup.get(editor) && Base.ElementLookup.get(editor)['editor']
          editorStyleClass = Base.ElementLookup.get(editor)['editor']['styleClass']

        fileStyleClass = ''
        if Base.ElementLookup.get(editor) && Base.ElementLookup.get(editor)['file']
          fileStyleClass = Base.ElementLookup.get(editor)['file']['styleClass']

        # always remove editor level from head
        if editorStyleClass
          this.removeStyleElementFromHead(editorStyleClass)

        # if file level, only remove from head if no other editors exist for the file
        # associated with this editor
        if fileStyleClass
          uri = @utils.normalizePath editor.getPath()
          editors = @utils.getTextEditors {uri : uri}

          if editors.length == 0
            this.removeStyleElementFromHead fileStyleClass

        # remove from ElementLookup
        Base.ElementLookup.delete(editor)

    # parse the css and decorate with the styleKey in the selectors to narrow
    # the scope in which this style sheet applies.  For incstance, if we are
    # adding a style at the editor level, the editor element class will have
    # a unique styleKey added to it.  We then need to add this class to the css
    # selector, so the style is applied to only that one editor
    narrowStyleScope: (css, styleClass, scope) ->
      # Note: regex replace is not destructive, so css var is unaffected
      switch scope
        when "editor", "file", "fileType"
          # note how we tack on a class of '.editor' to more narrowly target to the editor only
          narrowedCss = css.replace(/atom-text-editor/gm, "atom-text-editor.#{styleClass}.editor")
          narrowedCss = narrowedCss.replace(/^(\.syntax--\w+)/gm, ".#{styleClass}.editor $1")
        when "pane", "window"
          narrowedCss = css.replace(/atom-text-editor/gm, ".#{styleClass} atom-text-editor")
          narrowedCss = narrowedCss.replace(/^(\.syntax--\w+)/gm, ".#{styleClass} $1")

      narrowedCss

    # This method adds "syntax--" to themes that are not compliant with the new
    # >atom 1.13 style syntax.  e.g
    # ".comment {"  -> ".syntax--comment {"
    # We skip any element that has "atom" in it.
    normalizeSyntaxScope: (css) ->
      lines = css.split "\n"
      normalizedCss = ''

      for line in lines
        if line.match /atom/
          normalizedCss += line + "\n"
          continue

        normalizedLine = line
        if line.match /^\..*\{/
          normalizedLine = line.replace /^\.(\w+)/, ".syntax--$1"

         normalizedCss += normalizedLine + "\n"

      normalizedCss

    getActivePaneElem: () ->
      atom.workspace.getActivePane().getElement();

    getActiveWindowElem: () ->
      $('atom-workspace-axis.vertical atom-pane-container.panes')[0]
