Immutable = require 'immutable'
data      = require './data'
history   = require './history'

{ undoIsPossible
  redoIsPossible
  pushOntoUndoStack } = history

actionsMap = {}

removeHighlight = (tile) ->
  tile.mergeDeep
    style: tile:
      borderColor: null
      zIndex: 0

highlight = (tile) ->
  tile.mergeDeep
    style: tile:
      borderColor: 'blue'
      borderWidth: 2
      zIndex: 1

actionsMap.selectTile = (state, rowId, tile) ->
  idx = state.getIn(['legend', 'colors']).indexOf tile
  newTile = highlight tile
  newState = state.updateIn ['legend', 'colors'], (xs) -> xs.map removeHighlight
  newState = newState.setIn ['legend', 'colors', idx], newTile
  newState = newState.set 'selectedTile', tile

updateBgColor = actionsMap.updateBgColor = (state, rowId, tile) ->
  rowIdx = rowId
  tileIdx = tile.get('id') - 1
  newTile  = tile.merge state.get 'selectedTile'
  state.setIn ['tileData', 'currentFrame', 'grid', rowIdx, tileIdx], newTile

updateFrame = actionsMap.updateFrame = (state) ->
  frame = state.getIn ['tileData', 'currentFrame']
  currentGrid = frame.get 'grid'
  currentId = frame.get 'id'
  oldFrame = state.getIn(['tileData', 'frames']).find (frame) ->
    frame.get('id') is currentId
  idx = state.getIn(['tileData', 'frames']).indexOf oldFrame
  newState = state.setIn ['tileData', 'frames', idx], frame

actionsMap.createNewFrame = (state) ->
  currentGrid  = state.getIn ['tileData', 'currentFrame', 'grid']
  newState = updateFrame state
  newGrid = Immutable.Map
    id: Date.now()
    grid: currentGrid
  newState.setIn ['tileData', 'frames'], newState.getIn(['tileData', 'frames']).push newGrid
          .setIn ['tileData', 'currentFrame'], newGrid

actionsMap.makeFrameCurrent = (state, frame) ->
  currentFrameId = state.getIn ['tileData', 'currentFrame', 'id']
  frameIsCurrent = Immutable.is currentFrameId, frame.get 'id'
  if frameIsCurrent
    state
  else
    updateFrame(state).setIn ['tileData', 'currentFrame'], frame

actionsMap.deleteFrame = (state) ->
  currentFrame = state.getIn ['tileData', 'currentFrame']
  idx = state.getIn(['tileData', 'frames']).indexOf currentFrame
  newFrames = state.getIn(['tileData', 'frames']).remove idx
  newState =
    if newFrames.count() is 0
      state.setIn ['tileData', 'frames'], data.InitialFrames
    else
      state.setIn ['tileData', 'frames'], newFrames
  newFrame = newState.getIn(['tileData', 'frames']).last()
  newState.setIn ['tileData', 'currentFrame'], newFrame

actionsMap.copyFrame = (state) ->
  state = updateFrame state
  state.set 'copiedFrame', state.getIn ['tileData', 'currentFrame']

actionsMap.pasteFrame = (state) ->
  grid = state.getIn ['copiedFrame', 'grid']
  state.setIn ['tileData', 'currentFrame', 'grid'], grid
       .set 'copiedFrame', null

actionsMap.clearFrame = (state) ->
  newState = updateFrame(state)
  currentFrame = newState.getIn ['tileData', 'currentFrame']
  idx = newState.getIn(['tileData', 'frames']).indexOf currentFrame
  newFrame = currentFrame.set 'grid', data.InitialFrame.get 'grid'
  state.setIn ['tileData', 'currentFrame'], newFrame
       .setIn ['tileData', 'frames', idx], newFrame

actionsMap.playFrames = (state) ->
  newState = updateFrame state
  frames = newState.getIn ['tileData', 'frames']
  (cycleFrames = (idx, arr) =>
    nextFrame = arr.get idx
    if nextFrame
      newState = newState.setIn ['tileData', 'currentFrame'], nextFrame
      @renderState newState
      setTimeout cycleFrames.bind(null, ++idx, arr), 100
  )(0, frames)
  newState

actionsMap.doUndo = (state) ->
  history = state.get 'history'
  future  = state.get 'future'
  if undoIsPossible history
    newTileData = history.pop().last()
    newFuture   = future.push history.last()
    newHistory  = history.pop()
    state =  state.set 'history', newHistory
                  .set 'future', newFuture
                  .set 'tileData', newTileData
    @renderState state
  else
    @renderState state

actionsMap.doRedo = (state) ->
  history = state.get 'history'
  future  = state.get 'future'
  if redoIsPossible future
    newTileData = future.last()
    newHistory  = pushOntoUndoStack history, future.last()
    newFuture   = future.pop()
    state =  state.set 'history', newHistory
                  .set 'future', newFuture
                  .set 'tileData', newTileData
    @renderState state
  else
    @renderState state

actionsMap.selectTool = (state, tool) ->
 state.setIn ['tools', 'selected'], tool

toolActionDispatch = (state, args...) ->
  toolActionsMap =
    brush: updateBgColor
  curTool = state.getIn ['tools', 'selected', 'name']
  toolActionsMap[curTool].apply @, [state].concat args

actionsMap.tileAction = (args...) ->
  toolActionDispatch.apply @, args

module.exports = actionsMap
