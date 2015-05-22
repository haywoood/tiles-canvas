React = require 'react'
Immutable = require 'immutable'


utils = {}


utils.partition = (size, list) ->
  list1 = list.slice 0, size
  list2 = list.slice size
  Immutable.List [list1, list2]


utils.actionHandler = (actionsMap, renderFn, mountNode) ->
  (state, fnName, args...) ->
    # our action functions are pure, and always return a new state object
    thisValue =
      renderFn: renderFn
      mountNode: mountNode
    newState = actionsMap[fnName].bind(thisValue).apply null, [state].concat args
    # we re-render our app with the updated state
    if newState
      renderFn mountNode, newState


utils.createGrid = (rows, cols, tile, id) ->
  Immutable.Map
    id: id
    grid: Immutable.List (for y in [1..rows]
            Immutable.List (for x in [1..cols]
              tile.mergeDeep id: x))


utils.createLegendTiles = (colors, tile) ->
  Immutable.List (for {backgroundColor, color} in colors
    tile.mergeDeep
      style:
        tile: backgroundColor: backgroundColor
        dot: backgroundColor: color)

module.exports = utils
