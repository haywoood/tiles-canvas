Immutable         = require 'immutable'
pushOntoUndoStack = require('./history').pushOntoUndoStack

# TODO Explain
module.exports = (actionsMap, renderFn, mountNode) ->
  renderState = renderFn.bind null, mountNode
  return (state, fnName, args...) ->
    context = renderState: renderState
    newHistory = pushOntoUndoStack state.get('history'), state.get 'tileData'
    state = state.set 'history', newHistory
    newState = actionsMap[fnName].bind(context).apply null, [state].concat args
    # we don't always get here because some actions render directly
    # like undo, redo, and play
    if newState
      newState = newState.set 'future', Immutable.List()
      renderState newState
