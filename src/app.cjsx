React                = require 'react'
Immutable            = require 'immutable'
ReactCanvas          = require 'react-canvas'
ImmutableRenderMixin = require 'react-immutable-render-mixin'
Surface              = ReactCanvas.Surface
Group                = ReactCanvas.Group
Layer                = ReactCanvas.Layer


# util fns
removeHighlight = (tile) ->
  tile.mergeDeep
    style: tile:
      borderColor: null
      zIndex: 0


highlight = (tile) ->
  tile.mergeDeep
    style: tile:
      borderColor: 'blue'
      borderWidth: 2
      zIndex: 1


# actions
handleSelectTile = (state, rowId, tile) ->
  idx = state.getIn(['legend', 'colors']).indexOf tile
  newTile = highlight tile
  newState = state.updateIn ['legend', 'colors'], (xs) -> xs.map removeHighlight
  newState = newState.setIn ['legend', 'colors', idx], newTile
  newState = newState.set 'selectedTile', tile


handleUpdateBgColor = (state, rowId, tile) ->
  rowIdx = rowId
  tileIdx = tile.get('id') - 1
  newTile  = tile.merge state.get 'selectedTile'
  newState = state.setIn ['tileGrid', rowIdx, tileIdx], newTile


# component styles
Styles = Immutable.Map
  TileRow: Immutable.Map
    width: 500
    height: 17
  Grid: Immutable.Map
    width: 500
    height: 510
    backgroundColor: "white"


# base tile model
BaseTile = Immutable.Map
  style: Immutable.Map
    tile: Immutable.Map
      width: 10
      height: 17
      backgroundColor: "white"
      borderColor: null
      borderWidth: 2
    dot: Immutable.Map
      width: 2,
      height: 2,
      backgroundColor: "red"


# app state
State = Immutable.Map
  actionHandler: null
  selectedTile: null
  tileGrid: Immutable.List []
  legend: Immutable.Map
    tilesPerRow: 9
    colors: Immutable.List []


# colors options for legend
colors = [
  { backgroundColor: "#444"   , color: "white"   }
  { backgroundColor: "blue"   , color: "white"   }
  { backgroundColor: "cyan"   , color: "blue"    }
  { backgroundColor: "red"    , color: "white"   }
  { backgroundColor: "pink"   , color: "white"   }
  { backgroundColor: "yellow" , color: "red"     }
  { backgroundColor: "#64c7cc", color: "cyan"    }
  { backgroundColor: "#00a64d", color: "#75f0c3" }
  { backgroundColor: "#f5008b", color: "#ffdbbf" }
  { backgroundColor: "#0469bd", color: "#75d2fa" }
  { backgroundColor: "#fcf000", color: "#d60000" }
  { backgroundColor: "#010103", color: "#fa8e66" }
  { backgroundColor: "#7a2c02", color: "#fff3e6" }
  { backgroundColor: "white"  , color: "red"     }
  { backgroundColor: "#f5989c", color: "#963e03" }
  { backgroundColor: "#ed1c23", color: "#fff780" }
  { backgroundColor: "#f7f7f7", color: "#009e4c" }
  { backgroundColor: "#e04696", color: "#9c2c4b" }
]


# React components
Tile = React.createClass
  mixins: [ImmutableRenderMixin]

  handleClick: ->
    @props.actionHandler @props.data

  render: ->
    style = @props.data.get 'style'
    wrapStyle = style.get('tile').merge
      top: @props.top
      left: @props.left
    dotStyle  = style.get('dot').merge
      top: @props.top + 11
      left: @props.left + 4

    return (
      <Group style={wrapStyle.toJS()} onTouchMove={@handleClick} onTouchStart={@handleClick}>
        <Layer style={dotStyle.toJS()} />
      </Group>
    )


TileRow = React.createClass
  mixins: [ImmutableRenderMixin]

  handleTileAction: (tile) ->
    @props.actionHandler @props.id, tile

  render: ->
    actionHandler = @handleTileAction
    offsetTop     = @props.offsetTop or 0
    offsetLeft    = @props.offsetLeft or 0
    top    = (@props.id * 17) + offsetTop
    styles = Styles.get 'TileRow'
    styles = styles.set 'top', top
    tiles  = @props.data.map (tile, i) ->
      id   = tile.get('id') or tile.get 'backgroundColor'
      left = (i * 10) + offsetLeft
      <Tile top={top} left={left} key={id} data={tile} actionHandler={actionHandler} />
    return (
      <Group top={top} style={styles.toJS()}>
        {tiles.toJS()}
      </Group>
    )


TileGrid = React.createClass
  mixins: [ImmutableRenderMixin]

  handleTileAction: (rowId, tile) ->
    @props.actionHandler 'updateBgColor', rowId, tile

  render: ->
    handleTileAction = @handleTileAction
    tileRows = @props.data.map (tileRow, i) ->
      <TileRow data={tileRow} actionHandler={handleTileAction} key={i} id={i} />

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


render = (mountNode, state) ->
  React.render <App data={state} />, mountNode


actionHandler = (actionsMap, renderFn, mountNode) ->
  (state, fnName, args...) ->
    # our action functions are pure, and always return a new state object
    newState = actionsMap[fnName].apply null, [state].concat args
    # we re-render our app with the updated state
    renderFn mountNode, newState


createGrid = (rows, cols, tile) ->
  Immutable.List (for y in [1..rows]
    Immutable.List (for x in [1..cols]
      tile.mergeDeep id: x))


createLegendTiles = (colors, tile) ->
  Immutable.List (for {backgroundColor, color} in colors
    tile.mergeDeep
      style:
        tile: backgroundColor: backgroundColor
        dot: backgroundColor: color)


# app setup
mountNode = document.getElementsByTagName('body')[0]


actionsMap =
  updateBgColor: handleUpdateBgColor
  selectTile: handleSelectTile


state = State.mergeDeep
  actionHandler: actionHandler(actionsMap, render, mountNode)
  tileGrid: createGrid 30, 50, BaseTile
  legend: colors: createLegendTiles colors, BaseTile


selectedTile = state.getIn ['legend', 'colors', 0]
state = state.set 'selectedTile', selectedTile


# initial render
render mountNode, state
