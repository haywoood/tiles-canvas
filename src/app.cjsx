React          = require 'react'
Immutable      = require 'immutable'
ImmRenderMixin = require 'react-immutable-render-mixin'

TileGrid      = require './components/grid'
Legend        = require './components/legend'
FrameControls = require './components/frame-controls'
Tools         = require './components/tools'

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
    width      = @props.data.get 'width'
    height     = @props.data.get 'height'
    toolsData  = @props.data.get 'tools'
    legendData = @props.data.get 'legend'

    approxWidth   = Math.round(width / tileWidth) * tileWidth
    approxHeight  = Math.round(height / tileHeight) * tileHeight

    frames        = @props.data.getIn ['tileData', 'frames']
    currentFrame  = @props.data.getIn ['tileData', 'currentFrame']
    copiedFrame   = @props.data.get 'copiedFrame'

    return (
      <div className="Tiles">
        <div className="u-flexColumn">
          <Legend data={legendData} actionHandler={@actionHandler} />
          <Tools data={toolsData} copiedFrame={copiedFrame} actionHandler={@actionHandler} />
        </div>
        <div style={display: 'flex', flexDirection: 'column'}>
          <FrameControls actionHandler={@actionHandler} frames={frames} currentFrame={currentFrame} />
          <div className="TileGrid">
            <div className="u-displayFlex">
              <TileGrid data={currentFrame}
                        width={approxWidth} height={approxHeight}
                        actionHandler={@actionHandler} />
            </div>
          </div>
        </div>
      </div>
    )

render = (mountNode, state) ->
  React.render <App data={state} />, mountNode
  return null

mountNode = document.getElementsByTagName('body')[0]

state = State.mergeDeep
  actionHandler: actionHandler(actionsMap, render, mountNode)
  tileData:
    currentFrame: InitialFrame
    frames: Immutable.List.of InitialFrame
  legend: colors: LegendTiles

selectedTile = state.getIn ['legend', 'colors', 0]
state = state.set 'selectedTile', selectedTile
state = state.set 'history', Immutable.List.of state.get 'tileData'

# initial render
render mountNode, state
