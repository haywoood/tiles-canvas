Immutable = require 'immutable'

utils = {}

utils.partition = (size, list) ->
  list1 = list.slice 0, size
  list2 = list.slice size
  Immutable.List [list1, list2]

module.exports = utils
