$ = jQuery = require 'jquery'

module.exports =
  class Utils

    constructor: ->

    # shaddowRoot is defunct
    getActiveShadowRoot: ->
      atom.workspace.getActiveTextEditor().getElement().shadowRoot

    # Return the shadowRoot for the passed textEditor
    getShadowRoot: (editor) ->
      editor.getElement().shadowRoot
      console.log "Utils.getShadowRoot: entered"

    # adding the theme at editor level I could only get to work partial post- 
    # Atom 1.13.  Leaving in as a template
    getActiveEditorElement: ->
      atom.workspace.getActiveTextEditor().getElement()
      # $(atom.workspace.getActiveTextEditor().getElement()).parent()[0]

    # Return the shadowRoot for the passed textEditor
    getEditorElement: (editor) ->
      console.log "Utils.getEditorElement: entered"
      editor.getElement()
      # $(editor.getElement()).parent()[0]

   # We are now a window level themer
   # There's only one window, and it's always active
    # getActiveWindowElement: ->
    #   atom.workspace.getActiveTextEditor().getElement()

    # Return the "all panes" container ('atom-pane-container'), which we're loosely
    # referring to as a 'window'.
    getWindowElement: () ->
      console.log "vt:Utils.getWindowElement: entered"
      console.log  
      document.getElementsByTagName('atom-pane-container')[0]

    doIt: ->
      7

    # This returns the active file in the editor
    # e.g ""C:\vtstuff\tmp\dummy2.js""
    # normalized to unix format
    getActiveFile: ->
      atom.workspace.getActiveTextEditor().getURI().replace(/\\/g, '/')

    # return all the textEditors for a given parm type.  e.g if
    # params = {uri : '/myPath/abc.txt'}
    # then return all textEditors that are open on '/myPath/abc.txt'
    getTextEditors: (params)->
      result

      editors = atom.workspace.getTextEditors()

      if params.uri?
        result = (editor for editor in editors when editor.getURI() && editor.getURI().replace(/\\/g, '/') == params.uri)

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

       