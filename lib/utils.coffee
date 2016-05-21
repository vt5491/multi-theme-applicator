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

    # this is just a convenince for testing
    getHumaneCssString: ->
      """
atom-text-editor,
:host {
  background-color: #e3d5c1;
  color: #000000;
}
atom-text-editor .wrap-guide,
:host .wrap-guide {
  background-color: #a68a4a;
}
atom-text-editor .indent-guide,
:host .indent-guide {
  color: #373b41;
}
atom-text-editor .invisible-character,
:host .invisible-character {
  color: #373b41;
}
atom-text-editor .gutter,
:host .gutter {
  background-color: #edcfa3;
  color: #a68a4a;
}
atom-text-editor .gutter .line-number.cursor-line,
:host .gutter .line-number.cursor-line {
  background-color: #a68a4a;
  color: #edcfa3;
}
atom-text-editor .gutter .line-number.cursor-line-no-selection,
:host .gutter .line-number.cursor-line-no-selection {
  color: #edcfa3;
}
atom-text-editor .gutter .line-number.folded,
:host .gutter .line-number.folded,
atom-text-editor .gutter .line-number:after,
:host .gutter .line-number:after,
atom-text-editor .fold-marker:after,
:host .fold-marker:after {
  color: #edcfa3;
}
atom-text-editor .invisible,
:host .invisible {
  color: #000000;
}
atom-text-editor .cursor,
:host .cursor {
  color: white;
}
atom-text-editor .selection .region,
:host .selection .region {
  background-color: #d3bd9e;
}
atom-text-editor .search-results .marker .region,
:host .search-results .marker .region {
  background-color: transparent;
  border: 1px solid #a68a4a;
}
atom-text-editor .search-results .marker.current-result .region,
:host .search-results .marker.current-result .region {
  border: 1px solid #400080;
}
.comment {
  color: #937a42;
}
.entity.name.type {
  color: #400080;
}
.entity.other.inherited-class {
  color: #259241;
}
.keyword {
  color: #400080;
}
.keyword.control {
  color: #400080;
}
.keyword.operator {
  color: #000000;
}
.keyword.other.special-method {
  color: #81a2be;
}
.keyword.other.unit {
  color: #c04040;
}
.storage {
  color: #305fb6;
}
.storage.modifier {
  color: #400080;
}
.constant {
  color: #259241;
}
.constant.character.escape {
  color: #305fb6;
}
.constant.numeric {
  color: #259241;
}
.constant.other.color {
  color: #305fb6;
}
.constant.other.symbol {
  color: #259241;
}
.variable {
  color: #000000;
}
.variable.interpolation {
  color: #760f0f;
}
.variable.parameter.function {
  color: #000000;
}
.invalid.illegal {
  background-color: #a31515;
  color: #e3d5c1;
}
.string {
  color: #259241;
}
.string.regexp {
  color: #259241;
}
.string.regexp .source.ruby.embedded {
  color: #c04040;
}
.string.other.link {
  color: #a31515;
}
.punctuation.definition.comment {
  color: #6c4915;
}
.punctuation.definition.string {
  color: #259241;
}
.punctuation.definition.variable,
.punctuation.definition.parameters,
.punctuation.definition.array {
  color: #000000;
}
.punctuation.definition.heading,
.punctuation.definition.identity {
  color: #81a2be;
}
.punctuation.definition.bold {
  color: #c04040;
  font-weight: bold;
}
.punctuation.definition.italic {
  color: #400080;
  font-style: italic;
}
.punctuation.section.embedded {
  color: #760f0f;
}
.support.class {
  color: #305fb6;
}
.support.property-name {
  color: #305fb6;
}
.support.function {
  color: #305fb6;
}
.support.function.any-method {
  color: #81a2be;
}
.class .xml.entity.tag {
  color: #6c4915;
}
.class .comment.documentation {
  color: #937a42;
}
.class .comment .punctuation {
  color: #6c4915;
}
.entity.name.function {
  color: #305fb6;
}
.entity.name.class,
.entity.name.type.class {
  color: #305fb6;
}
.entity.name.section {
  color: #305fb6;
}
.entity.name.tag {
  color: #400080;
}
.entity.other.attribute-name.xml {
  color: #305fb6;
}
.entity.other.attribute-name {
  color: #400080;
}
.entity.other.attribute-name.id {
  color: #81a2be;
}
.meta.class {
  color: #000000;
}
.meta.link {
  color: #c04040;
}
.meta.require {
  color: #81a2be;
}
.meta.selector {
  color: #400080;
}
.meta.separator {
  background-color: #373b41;
  color: #000000;
}
.none {
  color: #000000;
}
.markup.bold {
  color: #c04040;
  font-weight: bold;
}
.markup.changed {
  color: #400080;
}
.markup.deleted {
  color: #a31515;
}
.markup.italic {
  color: #400080;
  font-style: italic;
}
.markup.heading .punctuation.definition.heading {
  color: #81a2be;
}
.markup.inserted {
  color: #259241;
}
.markup.list {
  color: #a31515;
}
.markup.quote {
  color: #c04040;
}
.markup.raw.inline {
  color: #259241;
}
.source.gfm .markup {
  -webkit-font-smoothing: auto;
}
.source.gfm .markup.heading {
  color: #259241;
}
atom-text-editor[mini] .scroll-view,
:host([mini]) .scroll-view {
  padding-left: 1px;
}
      """
