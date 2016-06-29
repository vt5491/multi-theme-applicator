module.exports =
  class Utils

    constructor: ->

    getActiveShadowRoot: ->
      atom.workspace.getActiveTextEditor().getElement().shadowRoot

    #vt add
    # return the shadowRoot for the passed textEditor
    getShadowRoot: (editor) ->
      #result
      editor.getElement().shadowRoot
    #vt end
    doIt: ->
      7

    #vt add
    getActiveURI: ->
      #atom.workspace.getActiveTextEditor().getActiveFilePath()
      atom.workspace.getActiveTextEditor().getURI()

    # return all the textEditors for a given parm type.  e.g if
    # params = {uri : '/myPath/abc.txt'}
    # then return all textEditors that are open on '/myPath/abc.txt'
    getTextEditors: (params)->
      result
      console.log("Util.getTextEditors: params=#{params}")
      console.log("Util.getTextEditors: params.uri=#{params.uri}")

      editors = atom.workspace.getTextEditors()
      console.log("Utils.getTextEditors: editors=#{editors}")
      console.log "params.uri= #{params.uri}"
      result

      if params.uri?
        console.log "Utils.getTextEditors: e1.uri= #{editors[0].getURI()}"
        #result = editors.filter (e) -> e.getURI == params.uri
        #result = (editor for editor in editors when editor.getURI() == params.uri)
        result = (editor for editor in editors when editor.getURI() == params.uri)

      console.log "Utils.getTextEditors: result=#{result}"
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
      console.log "now resetting pane id #{pane.id}"
      pane.activateNextItem()
      pane.activatePreviousItem()
    #vt end
