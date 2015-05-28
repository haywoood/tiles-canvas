React          = require 'react'
ImmRenderMixin = require 'react-immutable-render-mixin'
Immutable      = require 'immutable'

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

module.exports = FrameControls
