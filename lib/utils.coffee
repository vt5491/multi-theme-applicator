module.exports =
  class Utils

    constructor: ->

    getActiveShadowRoot: ->
      atom.workspace.getActiveTextEditor().getElement().shadowRoot

    doIt: ->
      7
