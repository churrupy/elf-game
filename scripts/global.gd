extends Node

var NPCS = {}
var NEARBY_NPCS: Array[String] = []
var FOCUS_NPCS = []
var TICKS: int = 0

var FOCUS_TARGET: String
var FOCUS_LOCATION: Vector2



#var SIDEBAR_SIZE = Vector2(300, Global.SCREEN_SIZE[1])
#const MAIN_FRAME_SIZE = Vector2(SCREEN_SIZE[0] - SIDEBAR_SIZE[0], SCREEN_SIZE[1])
#var CENTER_FRAME_POSITION = Vector2(SIDEBAR_SIZE[0], 0)
#var MAP_CENTER: Vector2 = Vector2(Constants.MAIN_FRAME_SIZE[0]/2 + Constants.MAIN_FRAME_POSITION[0], Constants.MAIN_FRAME_SIZE[1]/2)


var X_RANGE
var Y_RANGE
