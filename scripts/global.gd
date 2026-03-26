extends Node

var NPCS = {}
var NEARBY_NPCS = []
var FOCUS_NPCS = []
var TICKS = 0

var FOCUS_TARGET
var FOCUS_LOCATION

var PLAYER_LOCATION = [0,0]

var MAP_CENTER = Vector2(Constants.MAIN_FRAME_SIZE[0]/2 + Constants.MAIN_FRAME_POSITION[0], Constants.MAIN_FRAME_SIZE[1]/2)

var X_RANGE
var Y_RANGE
