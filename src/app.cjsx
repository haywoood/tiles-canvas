React = require 'react'
ReactCanvas = require 'react-canvas'
Immutable = require 'immutable'
Surface = ReactCanvas.Surface
Group = ReactCanvas.Group
Layer = ReactCanvas.Layer

GridStyle = Immutable.Map
  width: 500
  height: 510
  flexDirection: "row"
  flexWrap: "wrap"
  backgroundColor: "white"

TileStyle = Immutable.Map
  wrap: Immutable.Map
    width: 10
    height: 17
    backgroundColor: "white"
    alignItems: "center"
    justifyContent: "flex-end"
    paddingBottom: 4
  dot: Immutable.Map
    width: 2,
    height: 2,
    backgroundColor: "red"

Tile = React.createClass
  handleClick: ->
    console.log @props.id

  render: ->
    wrapStyle = TileStyle.get 'wrap'
    dotStyle  = TileStyle.get 'dot'

    return (
      <Group style={wrapStyle.toJS()} onClick={@handleClick}>
        <Layer style={dotStyle.toJS()} />
      </Group>
    )

App = React.createClass
  render: ->
    tiles = (<Tile id={i} key={i} /> for i in [1..1500])

    return (
      <Surface top={0} left={0} width={500} height={510} enableCSSLayout={true}>
        <Group style={GridStyle.toJS()}>
          {tiles}
        </Group>
      </Surface>
    )

mountNode = document.getElementsByClassName('Tiles')[0]
React.render <App />, mountNode
