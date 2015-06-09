React          = require 'react'
ReactCanvas    = require 'react-canvas'
Immutable      = require 'immutable'
ImmRenderMixin = require 'react-immutable-render-mixin'
TileRow        = require './tile-row'
Surface        = ReactCanvas.Surface
utils          = require '../utils'
data           = require '../data'

{ partition } = utils

{TileDimensions: { tileWidth, tileHeight}} = data

Legend = React.createClass
  mixins: [ImmRenderMixin]

  handleTileAction: (x, y, tile) ->
    @props.actionHandler 'selectTile', y, tile

  render: ->
    colors           = @props.data.get 'colors'
    handleTileAction = @handleTileAction
    tilesPerRow      = @props.data.get 'tilesPerRow'
    width            = (tileWidth * tilesPerRow) + 4
    rowSpacing       = 7

    rows = partition(tilesPerRow, colors).map (row, i) ->
      topOffset = if i > 0 then rowSpacing else 2
      <TileRow data={row}
               topOffset={topOffset}
               offsetLeft={2}
               actionHandler={handleTileAction}
               key={i} id={i} />

    height = (rows.size * rowSpacing) + (tileHeight * rows.size) + 4

    return (
      <div className="Legend">
        <Surface top={0} left={0} height={height} width={width}>
          {rows.toJS()}
        </Surface>
      </div>
    )

module.exports = Legend
