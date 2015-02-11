React = require 'react'
ReactCanvas = require 'react-canvas'
Immutable = require 'immutable'
Surface = ReactCanvas.Surface
Group = ReactCanvas.Group
Layer = ReactCanvas.Layer

App = React.createClass
  render: ->
    <h1>Tiles</h1>

mountNode = document.getElementsByClassName('Tiles')[0]
React.render <App />, mountNode
