Immutable = require 'immutable'

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

actionsMap.updateBgColor = (state, rowId, tile) ->
  rowIdx = rowId
  tileIdx = tile.get('id') - 1
  newTile  = tile.merge state.get 'selectedTile'
  newState = state.setIn ['currentFrame', 'grid', rowIdx, tileIdx], newTile

updateFrame = actionsMap.updateFrame = (state) ->
  frame = state.get 'currentFrame'
  currentGrid = frame.get 'grid'
  currentId = frame.get 'id'
  oldFrame = state.get('frames').find (frame) ->
    frame.get('id') is currentId
  idx = state.get('frames').indexOf oldFrame
  newState = state.setIn ['frames', idx], frame

actionsMap.createNewFrame = (state) ->
  currentGrid  = state.getIn ['currentFrame', 'grid']
  newState = updateFrame state
  newGrid = Immutable.Map
    id: Date.now()
    grid: currentGrid
  newState.set 'frames', newState.get('frames').push newGrid
          .set 'currentFrame', newGrid

actionsMap.makeFrameCurrent = (state, frame) ->
  updateFrame(state).set 'currentFrame', frame

actionsMap.playFrames = (state) ->
  newState = updateFrame state
  frames = newState.get 'frames'
  (cycleFrames = (idx, arr) =>
    nextFrame = arr.get idx
    if nextFrame
      newState = newState.set 'currentFrame', nextFrame
      @renderFn @mountNode, newState
      setTimeout cycleFrames.bind(null, ++idx, arr), 100
  )(0, frames)
  newState

module.exports = actionsMap
