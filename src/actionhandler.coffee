Immutable         = require 'immutable'
pushOntoUndoStack = require('./history').pushOntoUndoStack

# TODO Explain
module.exports = (actionsMap, renderFn, mountNode) ->
  (state, fnName, args...) ->
    context =
      renderFn: renderFn
      mountNode: mountNode
    newHistory = pushOntoUndoStack state.get('history'), state.get 'tileData'
    state = state.set 'history', newHistory
    newState = actionsMap[fnName].bind(context).apply null, [state].concat args
    renderFn mountNode, newState
