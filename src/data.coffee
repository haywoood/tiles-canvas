Immutable = require 'immutable'
round = Math.round

data = {}

TileDimensions = data.TileDimensions =
  tileWidth: 10
  tileHeight: 17
  dotOffset:
    top: 12
    left: 4
  dotWidth: 2
  dotHeight: 2

{ tileWidth, tileHeight, dotWidth, dotHeight } = TileDimensions

createGrid = data.createGrid = (rows, cols, tile, id) ->
  Immutable.Map
    id: id
    grid: Immutable.List (for y in [1..rows]
            Immutable.List (for x in [1..cols]
              tile.mergeDeep id: x))

createLegendTiles = data.createLegendTiles = (colors, tile) ->
  Immutable.List (for {backgroundColor, color} in colors
    tile.mergeDeep
      style:
        tile: backgroundColor: backgroundColor
        dot: backgroundColor: color)

BaseTile = data.BaseTile = Immutable.Map
  style: Immutable.Map
    tile: Immutable.Map
      width: tileWidth
      height: tileHeight
      backgroundColor: "white"
      borderColor: null
      borderWidth: 2
    dot: Immutable.Map
      width: dotWidth
      height: dotHeight
      backgroundColor: "red"

State = data.State = Immutable.Map
  actionHandler: null
  selectedTile: null
  currentFrame: Immutable.Map()
  copiedFrame: null
  frames: Immutable.List()
  width: 350
  height: 400
  legend: Immutable.Map
    tilesPerRow: 9
    colors: Immutable.List()

# colors options for legend
Colors = data.Colors = [
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

InitialFrame = data.InitialFrame = createGrid round(State.get('height') / 17),
                                              round(State.get('width') / 10),
                                              BaseTile,
                                              Date.now()

data.InitialFrames = Immutable.List.of InitialFrame

data.LegendTiles = createLegendTiles Colors, BaseTile

module.exports = data
