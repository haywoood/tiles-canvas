React = require 'react/addons'
Immutable = require 'immutable'
ImmRenderMixin = require 'react-immutable-render-mixin'

equal = Immutable.is

Tools = React.createClass
  mixins: [ImmRenderMixin]

  render: ->
    ah            = @props.actionHandler
    tools         = @props.data
    copiedFrame   = @props.copiedFrame

    selectedTool  = tools.get 'selected'
    copyFrameFn   = ah.bind null, 'copyFrame'
    updateTileFn  = ah.bind null, 'updateFrame'
    playFramesFn  = ah.bind null, 'playFrames'
    pasteFrameFn  = ah.bind null, 'pasteFrame'
    clearFrameFn  = ah.bind null, 'clearFrame'
    deleteFrameFn = ah.bind null, 'deleteFrame'
    undoFn        = ah.bind null, 'doUndo'
    redoFn        = ah.bind null, 'doRedo'

    toolButtons = tools.get('options').map (tool) ->
      name = tool.get 'name'
      display = tool.get 'display'
      args = tool.get 'actionArgs'
      isSelectedTool = equal tool, selectedTool
      action = ah.bind null, 'selectTool', tool
      classNames = React.addons.classSet
        NavButton: true
        activeTool: isSelectedTool
      <div className={classNames} style={width: 60} onClick={action}>
        {display}
      </div>

    <div className="u-flexColumn">
      {toolButtons.toJS()}
      <div className="NavButton" onClick={updateTileFn}>Save</div>
      <div className="NavButton" onClick={undoFn}>Undo</div>
      <div className="NavButton" onClick={redoFn}>Redo</div>
      <div className="NavButton" onClick={clearFrameFn}>Clear Frame</div>
      <div className="NavButton" onClick={deleteFrameFn}>Delete Frame</div>
      <div className="NavButton" onClick={copyFrameFn}>Copy Frame</div>
      {if copiedFrame
        <div className="NavButton" onClick={pasteFrameFn}>Paste Copied Frame</div>
      }
      <div className="NavButton" onClick={playFramesFn}>Play</div>
      <div className="NavButton" onClick={@props.exportImageAction}>Export to .png</div>
    </div>

module.exports = Tools
