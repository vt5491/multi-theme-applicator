module.exports =
  class Utils

    constructor: ->

    getActiveShadowRoot: ->
      atom.workspace.getActiveTextEditor().getElement().shadowRoot

    # Return the shadowRoot for the passed textEditor
    getShadowRoot: (editor) ->
      editor.getElement().shadowRoot

    doIt: ->
      7

    # This returns the active file in the editor
    # e.g ""C:\vtstuff\tmp\dummy2.js""
    getActiveURI: ->
      #atom.workspace.getActiveTextEditor().getActiveFilePath()
      atom.workspace.getActiveTextEditor().getURI()

    # return all the textEditors for a given parm type.  e.g if
    # params = {uri : '/myPath/abc.txt'}
    # then return all textEditors that are open on '/myPath/abc.txt'
    getTextEditors: (params)->
      result

      editors = atom.workspace.getTextEditors()
      result

      if params.uri?
        result = (editor for editor in editors when editor.getURI() == params.uri)

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
