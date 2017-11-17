$ = jQuery = require 'jquery'
Base = require './base'

module.exports =
  class Utils

    constructor: ->
    # adding the theme at editor level I could only get to work partial post-
    # Atom 1.13.  Leaving in as a template
    getActiveEditorElement: ->
      atom.workspace.getActiveTextEditor().getElement()

    # Return the shadowRoot for the passed textEditor
    getEditorElement: (editor) ->
      editor.getElement()

    # Return the "all panes" container ('atom-pane-container'), which we're loosely
    # referring to as a 'window'.
    getWindowElement: () ->
      document.getElementsByTagName('atom-pane-container')[0]

    doIt: ->
      7

    # This returns the active file in the editor
    # e.g ""C:\vtstuff\tmp\dummy2.js""
    # normalized to unix format
    getActiveFile: (ed) ->
      editor = ed || atom.workspace.getActiveTextEditor()
      fn = null
      if editor && editor.getURI()
        fn = editor.getURI().replace(/\\/g, '/')

      fn

    # return all the textEditors for a given parm type.  e.g if
    # params = {uri : '/myPath/abc.txt'}
    # then return all textEditors that are open on '/myPath/abc.txt'
    getTextEditors: (params)->
      result

      editors = atom.workspace.getTextEditors()

      if params.uri?
        result = (editor for editor in editors when editor.getURI() && editor.getURI().replace(/\\/g, '/') == params.uri)

      else if params.fileExt?
        re = new RegExp ".#{params.fileExt}$"

        result = (editor for editor in editors when editor.getURI() && editor.getURI().match re)

      result

    # reset all panes.  This is just a way to reset the panes to elminate any
    # unintended side effects from the dynamic theming
    resetPanes: ->
      for pane in atom.workspace.getPanes()
        this.resetPane pane

    # reset a pane just in case there have been residual effects from theming
    # operations.  For instance, if the theme is changed on a non-active editor
    # under a pane, it can sometimes "bleed" into the active editor on the pane.
    # Currently, we just reset by doing the API equivalent of switching to the next
    # tab, and then switching back.
    resetPane: (pane) ->
      pane.activateNextItem()
      pane.activatePreviousItem()

    # Normalize file paths to the standard format.  This means converting
    # it to unix format with '/' instead of '\'. However, we refrain from calling
    # this method "UnixfyPath" to resevere the right to use windows format
    # (or some other format) in the future, and thus calling it "normalizeFilePath"
    # is more flexible.  Note: we don't currently use much because
    # it's usually easier to say myString.replace(/blah/)
    # than @utils.normalizePath(myString)
    normalizePath: (fn) ->
      fn.replace(/\\/g,'/')

     # take #102030 and return "rgb(16, 32, 48)"
     hexToRgb: (hex) ->
       # remove leading '#', if any
       hex = hex.replace(/^#/,'')

       bigint = parseInt(hex, 16);
       r = (bigint >> 16) & 255;
       g = (bigint >> 8) & 255;
       b = bigint & 255;

       "rgb(#{r}, #{g}, #{b})"

    # get the themeName from Base.ThemeLookup given a theme path
    getThemeName: (themePath)->
      themeName = ''
      for themeObj in Base.ThemeLookup
        if themeObj['baseDir'] == themePath
          themeName = themeObj['themeName']
          break

      themeName

    # This is a work in progress.  I actually don't need it at the moment.
    # The problem is it's very hard to distinguish between 'mta-file' and
    # 'mta-file-type'
    hasMtaFileClass: (element)->
      elemClass = $(element).attr 'class'
      elemClass.match /mta-file-/

    hasMtaFileTypeClass: (element)->
      elemClass.match /mta-fileType-/

    getFileExt: (fileName) ->
      fileExt = ''
      if match = fileName.match(/\.(\w*)\s*$/)
        fileExt = match[1]

      fileExt
