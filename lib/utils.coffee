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

    #vt end
