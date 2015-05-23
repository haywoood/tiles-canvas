React = require 'react'
Immutable = require 'immutable'

utils = {}

utils.partition = (size, list) ->
  list1 = list.slice 0, size
  list2 = list.slice size
  Immutable.List [list1, list2]

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
