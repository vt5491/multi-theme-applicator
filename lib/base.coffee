module.exports =
  class Base

# @elementLookup
# defined in Base
# Used to keep track of elements that we have styled.  It's a WeakMap.  The key
# is the dom element (not jquery Element). We associate a js object with this key.
# The keys in the js object are:
# type, theme, class
# 
# type: The style scope: {windows, pane, file, editor}
# theme: the theme applied e.g "fairyfloss"
# styleClass: the style tag that has been added to the element's class e.g. 'mta-editor-style-1484974763214'  
    # ElementLookup = new WeakMap()
    # refer to this class var as Base.ElementLookup in other classes (not as Base.@ElementLookup)
    @ElementLookup = new WeakMap()
    # @ElementLookup = 10 
    # ElementLookup = 20 

    # constructor: ->
    #   console.log "Base.ctor: entered"