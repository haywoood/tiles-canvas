Immutable = require 'immutable'

history = {}

history.undoIsPossible = (history) ->
  history.size > 1

history.redoIsPossible = (future) ->
  future.size > 0

history.pushOntoUndoStack = (history, newState) ->
  equal = Immutable.is
  oldWatchableAppState = history.last()
  unless equal oldWatchableAppState, newState
    history.push newState
  else
    history

module.exports = history
