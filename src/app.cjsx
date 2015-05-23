React          = require 'react'
Immutable      = require 'immutable'
ReactCanvas    = require 'react-canvas'
ImmRenderMixin = require 'react-immutable-render-mixin'
Surface        = ReactCanvas.Surface
Group          = ReactCanvas.Group
Layer          = ReactCanvas.Layer

data          = require './data'
utils         = require './utils'
actionsMap    = require './actions'
actionHandler = require './actionhandler'

{ partition } = utils

{ State
  InitialFrame
  LegendTiles
  Colors } = data

# React components
Tile = React.createClass
  mixins: [ImmRenderMixin]

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
  mixins: [ImmRenderMixin]

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
  mixins: [ImmRenderMixin]

  handleTileAction: (rowId, tile) ->
    @props.actionHandler 'updateBgColor', rowId, tile

  handleExportTile: ->
    dataURL = @refs.grid.getDOMNode()
                        .toDataURL()
    window.open dataURL, '_blank'

  render: ->
    handleTileAction = @handleTileAction
    scale = @props.scale or 1

    copyFrameFn   = @props.actionHandler.bind null, 'copyFrame'
    updateTileFn  = @props.actionHandler.bind null, 'updateFrame'
    playFramesFn  = @props.actionHandler.bind null, 'playFrames'
    pasteFrameFn  = @props.actionHandler.bind null, 'pasteFrame'
    clearFrameFn  = @props.actionHandler.bind null, 'clearFrame'
    deleteFrameFn = @props.actionHandler.bind null, 'deleteFrame'

    tileRows = @props.data.get('grid').map (tileRow, i) ->
      <TileRow data={tileRow} scale={scale} actionHandler={handleTileAction} key={i} id={i} />

    return (
      <div className="TileGrid">
        <div className="u-displayFlex">
          <Surface ref="grid"
                   style={backgroundColor: 'white'}
                   top={0} left={0} width={500 * scale}
                   height={Math.floor 510 * scale}>{tileRows.toJS()}</Surface>
          <div className="u-flexColumn">
            <button onClick={updateTileFn}>Save</button>
            <button onClick={clearFrameFn}>Clear Frame</button>
            <button onClick={deleteFrameFn}>Delete Frame</button>
            <button onClick={copyFrameFn}>Copy Frame</button>
            {if @props.copiedFrame
              <button onClick={pasteFrameFn}>Paste Copied Frame</button>
            }
            <button onClick={playFramesFn}>Play</button>
            <button onClick={@handleExportTile}>Export to .png</button>
          </div>
        </div>
      </div>
    )

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

FrameControls = React.createClass
  mixins: [ImmRenderMixin]

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
  mixins: [ImmRenderMixin]

  actionHandler: (args...) ->
    @props.data.get('actionHandler').apply null, [@props.data].concat args

  render: ->
    frames = @props.data.get 'frames'
    currentFrame = @props.data.get 'currentFrame'
    copiedFrame = @props.data.get 'copiedFrame'
    return (
      <div className="Tiles">
        <Legend data={@props.data.get 'legend'} actionHandler={@actionHandler} />
        <div style={display: 'flex', flexDirection: 'column'}>
          <FrameControls actionHandler={@actionHandler} frames={frames} currentFrame={currentFrame} />
          <TileGrid data={@props.data.get 'currentFrame'}
                    copiedFrame={copiedFrame}
                    actionHandler={@actionHandler} />
        </div>
      </div>
    )

# app setup
render = (mountNode, state) ->
  React.render <App data={state} />, mountNode

mountNode = document.getElementsByTagName('body')[0]

#initialFrame = createGrid 30, 50, BaseTile, Date.now()

state = State.mergeDeep
  actionHandler: actionHandler(actionsMap, render, mountNode)
  currentFrame: InitialFrame
  frames: Immutable.List.of InitialFrame
  legend: colors: LegendTiles

selectedTile = state.getIn ['legend', 'colors', 0]

state = state.set 'selectedTile', selectedTile

# initial render
render mountNode, state
