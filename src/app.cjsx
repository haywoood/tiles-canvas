React = require 'react'
ReactCanvas = require 'react-canvas'
Immutable = require 'immutable'
ImmutableRenderMixin = require 'react-immutable-render-mixin'
Surface = ReactCanvas.Surface
Group = ReactCanvas.Group
Layer = ReactCanvas.Layer

# actions
handleUpdateBgColor = (state, rowId, tile) ->
  rowIdx = rowId
  tileIdx = tile.get('id') - 1
  newTile  = tile.set 'backgroundColor', 'cyan'
  newState = state.setIn ['tiles', rowIdx, tileIdx], newTile
  render newState

# component styles, uses css-layout to position canvas elements
Styles = Immutable.Map
  TileRow: Immutable.Map
    backgroundColor: 'cyan'
    width: 500
    height: 17
  Grid: Immutable.Map
    width: 500
    height: 510
    backgroundColor: "white"
  TileWrap: Immutable.Map
    width: 10
    height: 17
    backgroundColor: "white"
  TileDot: Immutable.Map
    width: 2,
    height: 2,
    backgroundColor: "red"

# app state
State = Immutable.Map
  actionHandler: null
  tileGrid: Immutable.List []

# React components
Tile = React.createClass
  mixins: [ImmutableRenderMixin]

  handleClick: ->
    @props.actionHandler 'updateBgColor', @props.rowId, @props.data

  render: ->
    bgColor   = @props.data.get 'backgroundColor'
    color     = @props.data.get 'color'
    wrapStyle = Styles.get('TileWrap').mergeDeep
      backgroundColor: bgColor
      top: @props.top
      left: @props.left
    dotStyle  = Styles.get('TileDot').mergeDeep
      backgroundColor: color
      top: @props.top + 11
      left: @props.left + 4

    return (
      <Group style={wrapStyle.toJS()} onTouchMove={@handleClick}
                                      onTouchStart={@handleClick}>
        <Layer style={dotStyle.toJS()} />
      </Group>
    )

TileRow = React.createClass
  mixins: [ImmutableRenderMixin]

  render: ->
    actionHandler = @props.actionHandler
    rowId = @props.id
    top   = rowId * 17
    styles = Styles.get 'TileRow'
    styles = styles.set 'top', top
    tiles = @props.data.map (tile, i) ->
      id = "y#{rowId}x#{tile.get 'id'}"
      left = i * 10
      <Tile top={top} left={left} rowId={rowId} key={id} data={tile} actionHandler={actionHandler} />
    <Group top={top} style={styles.toJS()}>
      {tiles.toJS()}
    </Group>

App = React.createClass
  mixins: [ImmutableRenderMixin]

  actionHandler: (args...) ->
    @props.data.get('actionHandler').apply null, [@props.data].concat args

  render: ->
    actionHandler = @actionHandler
    tileRows = @props.data.get('tiles').map (tileRow, i) ->
      <TileRow data={tileRow} actionHandler={actionHandler} key={i} id={i} />

    return (
      <Surface top={0} left={0} width={500} height={510}>
        <Group style={Styles.get('Grid').toJS()}>
          {tileRows.toJS()}
        </Group>
      </Surface>
    )

# helpers
render = (state) ->
  mountNode = document.getElementsByClassName('Tiles')[0]
  React.render <App data={state} />, mountNode

actionHandler = (actionsMap) -> (state, fnName, args...) ->
  actionsMap[fnName].apply null, [state].concat args

createGrid = (rows, cols) ->
  Immutable.List (for y in [1..rows]
    Immutable.List (for x in [1..cols]
      Immutable.Map
        id: x
        backgroundColor: "white"
        color: "red"))

# app setup
actionsMap =
  updateBgColor: handleUpdateBgColor

state = State.merge
  actionHandler: actionHandler actionsMap
  tiles: createGrid 30, 50

# initial render
render state
