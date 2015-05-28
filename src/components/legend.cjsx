React          = require 'react'
ReactCanvas    = require 'react-canvas'
Immutable      = require 'immutable'
ImmRenderMixin = require 'react-immutable-render-mixin'
TileRow        = require './row'
Surface        = ReactCanvas.Surface
utils          = require '../utils'

{ partition } = utils

Legend = React.createClass
  mixins: [ImmRenderMixin]

  handleTileAction: (rowId, tile) ->
    @props.actionHandler 'selectTile', rowId, tile

  render: ->
    colors           = @props.data.get 'colors'
    handleTileAction = @handleTileAction
    tilesPerRow      = @props.data.get 'tilesPerRow'
    width            = (10 * tilesPerRow) + 4
    rowSpacing       = 15

    rows = partition(tilesPerRow, colors).map (row, i) ->
      offsetTop = if i > 0 then rowSpacing else 2
      <TileRow data={row}
               offsetTop={offsetTop}
               offsetLeft={2}
               actionHandler={handleTileAction}
               key={i} id={i} />

    height = (rows.size * rowSpacing) + (17 * rows.size) + 4

    return (
      <div className="Legend">
        <Surface top={0} left={0} height={height} width={width}>
          {rows.toJS()}
        </Surface>
      </div>
    )

module.exports = Legend
