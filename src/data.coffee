Immutable            = require 'immutable'


data = {}


data.State = Immutable.Map
  actionHandler: null
  selectedTile: null
  currentFrame: Immutable.Map()
  frames: Immutable.List()
  legend: Immutable.Map
    tilesPerRow: 9
    colors: Immutable.List()


# colors options for legend
data.Colors = [
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


module.exports = data
