React          = require 'react'
ImmRenderMixin = require 'react-immutable-render-mixin'
ReactCanvas    = require 'react-canvas'
Group          = ReactCanvas.Group
Layer          = ReactCanvas.Layer

Tile = React.createClass
  mixins: [ImmRenderMixin]

  handleClick: ->
    @props.actionHandler @props.data

  render: ->
    style = @props.data.get 'style'

    wrapStyle = style.get('tile').merge
      top: @props.top
      left: @props.left

    dotStyle = style.get('dot').merge
      top: @props.top + 11
      left: @props.left + 4

    return (
      <Group style={wrapStyle.toJS()} onTouchMove={@handleClick} onTouchStart={@handleClick}>
        <Layer style={dotStyle.toJS()} />
      </Group>
    )

module.exports = Tile
