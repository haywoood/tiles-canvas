# TODO Explain
module.exports = (actionsMap, renderFn, mountNode) ->
  (state, fnName, args...) ->
    context =
      renderFn: renderFn
      mountNode: mountNode
    newState = actionsMap[fnName].bind(context).apply null, [state].concat args
    renderFn mountNode, newState
