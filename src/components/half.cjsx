React          = require 'react'
ReactCanvas    = require 'react-canvas'
Group          = ReactCanvas.Group
ImmRenderMixin = require 'react-immutable-render-mixin'
TileRow        = require './row'

TileHalf = React.createClass
  mixins: [ImmRenderMixin]

  handleTileAction: (rowId, tile) ->
    rowId = rowId + (@props.topOffset or 0)
    @props.actionHandler 'updateBgColor', rowId, tile

  render: ->
    { data, topOffset, multiplier } = @props
    tileRows = data.map (tileRow, i) =>
      <TileRow data={tileRow}
               topOffset={topOffset * 17}
               actionHandler={@handleTileAction} key={i} id={i} />
    <Group>{tileRows.toJS()}</Group>

module.exports = TileHalf