React          = require 'react'
Immutable      = require 'immutable'
ImmRenderMixin = require 'react-immutable-render-mixin'

TileGrid      = require './components/grid'
Legend        = require './components/legend'
FrameControls = require './components/frame-controls'

data          = require './data'
actionsMap    = require './actions'
actionHandler = require './actionhandler'

{ State
  InitialFrame
  TileDimensions
  LegendTiles
  Colors } = data

{ tileWidth, tileHeight, dotWidth, dotHeight } = TileDimensions

App = React.createClass
  mixins: [ImmRenderMixin]

  actionHandler: (args...) ->
    @props.data.get('actionHandler').apply null, [@props.data].concat args

  render: ->
    width = @props.data.get 'width'
    height = @props.data.get 'height'

    approxWidth   = Math.round(width / tileWidth) * tileWidth
    approxHeight  = Math.round(height / tileHeight) * tileHeight

    frames        = @props.data.get 'frames'
    currentFrame  = @props.data.get 'currentFrame'
    copiedFrame   = @props.data.get 'copiedFrame'
    copyFrameFn   = @actionHandler.bind null, 'copyFrame'
    updateTileFn  = @actionHandler.bind null, 'updateFrame'
    playFramesFn  = @actionHandler.bind null, 'playFrames'
    pasteFrameFn  = @actionHandler.bind null, 'pasteFrame'
    clearFrameFn  = @actionHandler.bind null, 'clearFrame'
    deleteFrameFn = @actionHandler.bind null, 'deleteFrame'

    return (
      <div className="Tiles">
        <div className="u-flexColumn">
          <Legend data={@props.data.get 'legend'} actionHandler={@actionHandler} />
          <div className="u-flexColumn">
            <div className="NavButton" onClick={updateTileFn}>Save</div>
            <div className="NavButton" onClick={clearFrameFn}>Clear Frame</div>
            <div className="NavButton" onClick={deleteFrameFn}>Delete Frame</div>
            <div className="NavButton" onClick={copyFrameFn}>Copy Frame</div>
            {if copiedFrame
              <div className="NavButton" onClick={pasteFrameFn}>Paste Copied Frame</div>
            }
            <div className="NavButton" onClick={playFramesFn}>Play</div>
            <div className="NavButton" onClick={@handleExportTile}>Export to .png</div>
          </div>
        </div>
        <div style={display: 'flex', flexDirection: 'column'}>
          <FrameControls actionHandler={@actionHandler} frames={frames} currentFrame={currentFrame} />
          <div className="TileGrid">
            <div className="u-displayFlex">
              <TileGrid data={@props.data.get 'currentFrame'}
                        width={approxWidth} height={approxHeight}
                        actionHandler={@actionHandler} />
            </div>
          </div>
        </div>
      </div>
    )

render = (mountNode, state) ->
  React.render <App data={state} />, mountNode

mountNode = document.getElementsByTagName('body')[0]

state = State.mergeDeep
  actionHandler: actionHandler(actionsMap, render, mountNode)
  currentFrame: InitialFrame
  frames: Immutable.List.of InitialFrame
  legend: colors: LegendTiles

selectedTile = state.getIn ['legend', 'colors', 0]
state = state.set 'selectedTile', selectedTile

# initial render
render mountNode, state
