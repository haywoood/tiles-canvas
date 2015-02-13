React                = require 'react'
Immutable            = require 'immutable'
ReactCanvas          = require 'react-canvas'
ImmutableRenderMixin = require 'react-immutable-render-mixin'
Surface              = ReactCanvas.Surface
Group                = ReactCanvas.Group
Layer                = ReactCanvas.Layer


# actions
handleUpdateBgColor = (state, rowId, tile) ->
  rowIdx = rowId
  tileIdx = tile.get('id') - 1
  newTile  = tile.set 'backgroundColor', 'cyan'
  newState = state.setIn ['tileGrid', rowIdx, tileIdx], newTile
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
  legend: Immutable.Map
    tilesPerRow: 9
    colors: Immutable.List [
      Immutable.Map backgroundColor: "#444"   , color: "white"
      Immutable.Map backgroundColor: "blue"   , color: "white"
      Immutable.Map backgroundColor: "cyan"   , color: "blue"
      Immutable.Map backgroundColor: "red"    , color: "white"
      Immutable.Map backgroundColor: "pink"   , color: "white"
      Immutable.Map backgroundColor: "yellow" , color: "red"
      Immutable.Map backgroundColor: "#64c7cc", color: "cyan"
      Immutable.Map backgroundColor: "#00a64d", color: "#75f0c3"
      Immutable.Map backgroundColor: "#f5008b", color: "#ffdbbf"
      Immutable.Map backgroundColor: "#0469bd", color: "#75d2fa"
      Immutable.Map backgroundColor: "#fcf000", color: "#d60000"
      Immutable.Map backgroundColor: "#010103", color: "#fa8e66"
      Immutable.Map backgroundColor: "#7a2c02", color: "#fff3e6"
      Immutable.Map backgroundColor: "#07c3f7", color: "#0d080c"
      Immutable.Map backgroundColor: "#f5989c", color: "#963e03"
      Immutable.Map backgroundColor: "#ed1c23", color: "#fff780"
      Immutable.Map backgroundColor: "#f7f7f7", color: "#009e4c"
      Immutable.Map backgroundColor: "#e04696", color: "#9c2c4b"
    ]


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
      <Group style={wrapStyle.toJS()} onTouchMove={@handleClick} onTouchStart={@handleClick}>
        <Layer style={dotStyle.toJS()} />
      </Group>
    )


TileRow = React.createClass
  mixins: [ImmutableRenderMixin]

  render: ->
    actionHandler = @props.actionHandler
    rowId  = @props.id
    top    = rowId * 17
    styles = Styles.get 'TileRow'
    styles = styles.set 'top', top
    tiles  = @props.data.map (tile, i) ->
      id   = tile.get('id') or tile.get 'backgroundColor'
      left = i * 10
      <Tile top={top} left={left} rowId={rowId} key={id} data={tile} actionHandler={actionHandler} />
    return (
      <Group top={top} style={styles.toJS()}>
        {tiles.toJS()}
      </Group>
    )


TileGrid = React.createClass
  mixins: [ImmutableRenderMixin]

  render: ->
    actionHandler = @props.actionHandler
    tileRows = @props.data.map (tileRow, i) ->
      <TileRow data={tileRow} actionHandler={actionHandler} key={i} id={i} />

    return (
      <div className="TileGrid">
        <Surface top={0} left={9} width={500} height={510}>
          <Group style={Styles.get('Grid').toJS()}>
            {tileRows.toJS()}
          </Group>
        </Surface>
      </div>
    )


Legend = React.createClass
  mixins: [ImmutableRenderMixin]

  render: ->
    colors        = @props.data.get 'colors'
    actionHandler = @props.actionHandler
    tilesPerRow   = @props.data.get 'tilesPerRow'
    width         = 10 * tilesPerRow
    height        = 17 * 2

    rows = partition(tilesPerRow, colors).map (row, i) ->
      <TileRow data={row} actionHandler={actionHandler} key={i} id={i} />

    return (
      <div className="Legend">
        <Surface top={0} left={0} width={width} height={height}>
          {rows.toJS()}
        </Surface>
      </div>
    )


App = React.createClass
  mixins: [ImmutableRenderMixin]

  actionHandler: (args...) ->
    @props.data.get('actionHandler').apply null, [@props.data].concat args

  render: ->
    return (
      <div className="Tiles">
        <Legend data={@props.data.get 'legend'} actionHandler={@actionHandler} />
        <TileGrid data={@props.data.get 'tileGrid'} actionHandler={@actionHandler} />
      </div>
    )


# helpers
partition = (size, list) ->
  list1 = list.slice 0, size
  list2 = list.slice size
  Immutable.List [list1, list2]


render = (state) ->
  mountNode = document.getElementsByTagName('body')[0]
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
  tileGrid: createGrid 30, 50


# initial render
render state
