React = require 'react'
ReactCanvas = require 'react-canvas'
Immutable = require 'immutable'
ImmutableRenderMixin = require 'react-immutable-render-mixin'
Surface = ReactCanvas.Surface
Group = ReactCanvas.Group
Layer = ReactCanvas.Layer

# actions
handleUpdateBgColor = (state, tile) ->
  newTile  = tile.set 'backgroundColor', 'cyan'
  id       = tile.get 'id'
  newState = state.setIn ['tiles', id], newTile
  render newState

# component styles
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

# app state
State = Immutable.Map
  actionHandler: null
  tiles: Immutable.List []

# React components
Tile = React.createClass
  mixins: [ImmutableRenderMixin]

  propTypes:
    data: React.PropTypes.instanceOf Immutable.Map

  handleClick: ->
    @props.actionHandler 'updateBgColor', @props.data

  render: ->
    bgColor   = @props.data.get 'backgroundColor'
    color     = @props.data.get 'color'
    wrapStyle = TileStyle.get('wrap').set 'backgroundColor', bgColor
    dotStyle  = TileStyle.get('dot').set 'backgroundColor', color

    return (
      <Group style={wrapStyle.toJS()} onClick={@handleClick}>
        <Layer style={dotStyle.toJS()} />
      </Group>
    )

App = React.createClass
  mixins: [ImmutableRenderMixin]

  propTypes:
    data: React.PropTypes.instanceOf Immutable.Map

  actionHandler: (args...) ->
    @props.data.get('actionHandler').apply null, [@props.data].concat args

  render: ->
    actionHandler = @actionHandler
    tiles = @props.data.get('tiles').map (tile) ->
      <Tile data={tile} actionHandler={actionHandler} key={tile.get 'id'} />

    return (
      <Surface top={0} left={0} width={500} height={510} enableCSSLayout={true}>
        <Group style={GridStyle.toJS()}>
          {tiles.toJS()}
        </Group>
      </Surface>
    )

# helpers
render = (state) ->
  mountNode = document.getElementsByClassName('Tiles')[0]
  React.render <App data={state} />, mountNode

actionHandler = (actionsMap) -> (state, fnName, args...) ->
  actionsMap[fnName].apply null, [state].concat args

# app setup
actionsMap =
  updateBgColor: handleUpdateBgColor

state = State.merge
  actionHandler: actionHandler actionsMap
  tiles: Immutable.Range(0, 1499).map((i) ->
    Immutable.Map
      id: i
      backgroundColor: "white"
      color: "red"
  ).toList()

# initial render
render state
