#$ = jQuery = require 'jquery'

module.exports =
  class Utils

    constructor: ->

    getActiveShadowRoot: ->
      console.log('Utils.getActiveShadowRoot: atom=' + atom)
      console.log('Utils.getActiveShadowRoot: atom.workspace.getActiveTextEditor()='
        #+ atom.workspace.getActiveTextEditor())
        + atom.workspace)
      # atom.workspace.getActiveTextEditor().getElement()[0].shadowRoot
      atom.workspace.getActiveTextEditor().getElement().shadowRoot

    doIt: ->
      7
