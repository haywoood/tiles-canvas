React                = require 'react'
Immutable            = require 'immutable'
ReactCanvas          = require 'react-canvas'
ImmutableRenderMixin = require 'react-immutable-render-mixin'
Surface              = ReactCanvas.Surface
Group                = ReactCanvas.Group
Layer                = ReactCanvas.Layer
actionsMap           = require './actions'
utils                = require './utils'
data                 = require './data'


{ render
  highlight
  partition
  createGrid
  actionHandler
  removeHighlight
  createLegendTiles } = utils


{ State
  Colors } = data


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


# React components
Tile = React.createClass
  mixins: [ImmutableRenderMixin]

  handleClick: ->
    @props.actionHandler @props.data

  render: ->
    scale = @props.scale or 1
    style = @props.data.get 'style'
    wrapStyle = style.get('tile').merge
      top: @props.top
      left: @props.left
    dotStyle  = style.get('dot').merge
      top: @props.top + Math.round (11 * scale)
      left: @props.left + (4 * scale)

    return (
      <Group style={wrapStyle.toJS()} onTouchMove={@handleClick} onTouchStart={@handleClick}>
        {if scale is 1
          <Layer style={dotStyle.toJS()} />
        }
      </Group>
    )


TileRow = React.createClass
  mixins: [ImmutableRenderMixin]

  handleTileAction: (tile) ->
    @props.actionHandler @props.id, tile

  render: ->
    scale = @props.scale or 1
    actionHandler = @handleTileAction
    offsetTop     = @props.offsetTop or 0
    offsetLeft    = @props.offsetLeft or 0
    top    = ((@props.id * 17) + offsetTop) * scale
    tiles  = @props.data.map (tile, i) ->
      id   = tile.get('id') or tile.get 'backgroundColor'
      left = Math.round ((i * 10) + offsetLeft) * scale
      <Tile top={top} scale={scale} left={left} key={id} data={tile} actionHandler={actionHandler} />
    return (
      <Group>
        {tiles.toJS()}
      </Group>
    )


TileGrid = React.createClass
  mixins: [ImmutableRenderMixin]

  handleTileAction: (rowId, tile) ->
    @props.actionHandler 'updateBgColor', rowId, tile

  render: ->
    handleTileAction = @handleTileAction
    scale = @props.scale or 1
    updateTileFn = @props.actionHandler.bind null, 'updateFrame'
    playFramesFn = @props.actionHandler.bind null, 'playFrames'
    tileRows = @props.data.get('grid').map (tileRow, i) ->
      <TileRow data={tileRow} scale={scale} actionHandler={handleTileAction} key={i} id={i} />

    return (
      <div className="TileGrid">
        <div className="u-displayFlex">
          <Surface style={backgroundColor: 'white'} top={0} left={0} width={500 * scale} height={Math.floor 510 * scale}>
            {tileRows.toJS()}
          </Surface>
          <div>
            <button onClick={updateTileFn}>Save</button>
            <button onClick={playFramesFn}>Play</button>
          </div>
        </div>
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


FrameControls = React.createClass
  mixins: [ImmutableRenderMixin]

  render: ->
    actionHandler = @props.actionHandler
    currentFrameId = @props.currentFrame.get 'id'
    createNewFrame = actionHandler.bind null, 'createNewFrame'
    frameNav = @props.frames.map (frame, i) ->
      makeFrameCurrent = actionHandler.bind null, 'makeFrameCurrent', frame
      frameIsCurrent = Immutable.is currentFrameId, frame.get 'id'
      content = if frameIsCurrent then "[#{i++}]" else i++

      <div onClick={makeFrameCurrent}>{content}</div>


    <div className="u-displayFlex">
      <div onClick={createNewFrame}>+</div>
      {frameNav.toJS()}
    </div>



App = React.createClass
  mixins: [ImmutableRenderMixin]

  actionHandler: (args...) ->
    @props.data.get('actionHandler').apply null, [@props.data].concat args

  render: ->
    frames = @props.data.get 'frames'
    currentFrame = @props.data.get 'currentFrame'
    return (
      <div className="Tiles">
        <Legend data={@props.data.get 'legend'} actionHandler={@actionHandler} />
        <div style={display: 'flex', flexDirection: 'column'}>
          <FrameControls actionHandler={@actionHandler} frames={frames} currentFrame={currentFrame} />
          <TileGrid data={@props.data.get 'currentFrame'} actionHandler={@actionHandler} />
        </div>
      </div>
    )


# app setup
render = (mountNode, state) ->
  React.render <App data={state} />, mountNode

mountNode = document.getElementsByTagName('body')[0]

initialFrame = createGrid 30, 50, BaseTile, Date.now()

state = State.mergeDeep
  actionHandler: actionHandler(actionsMap, render, mountNode)
  currentFrame: initialFrame
  frames: Immutable.List.of initialFrame
  legend: colors: createLegendTiles Colors, BaseTile

selectedTile = state.getIn ['legend', 'colors', 0]
state = state.set 'selectedTile', selectedTile

# initial render
render mountNode, state
