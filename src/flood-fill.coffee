Immutable = require 'immutable'

# this is pretty bad and should be refactored, couldn't
# get the algorithm working without taking advantage of mutability
# in the short term
tileEquals = (a, b) ->
  z = a.style.dot.backgroundColor is b.style.dot.backgroundColor
  t = a.style.tile.backgroundColor is b.style.tile.backgroundColor
  z and t

updateTileMut = (a, b) ->
  a.style.dot.backgroundColor = b.style.dot.backgroundColor
  a.style.tile.backgroundColor = b.style.tile.backgroundColor

floodFill = (mapData, x, y, oldVal, newVal) ->
  mapHeight = mapData.length
  mapWidth  = mapData[0].length
  if oldVal is null
    return if tileEquals mapData[y][x], newVal
    oldVal = Immutable.fromJS(mapData[y][x]).toJS()
  return unless tileEquals mapData[y][x], oldVal
  updateTileMut mapData[y][x], newVal
  if x > 0
    # left
    floodFill mapData, x-1, y, oldVal, newVal
  if y > 0
    # up
    floodFill mapData, x, y-1, oldVal, newVal
  if x < mapWidth - 1
    # right
    floodFill mapData, x+1, y, oldVal, newVal
  if y < mapHeight - 1
    # down
    floodFill mapData, x, y+1, oldVal, newVal

_floodFill = (mapData, x, y, oldVal, newVal) ->
  grid = mapData.toJS()
  floodFill grid, x, y, null, newVal.toJS()
  Immutable.fromJS grid

module.exports = _floodFill
