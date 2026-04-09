extends Node

#region game const
const TILE_SIZE = 64
#const SCREEN_SIZE = Vector2(1200, 660)
const MAP_SIZE = [10,10] # num tiles across
const BOTTOM_RIGHT = Vector2(MAP_SIZE[0]-1, MAP_SIZE[1]-1)
const NUM_NPCS = 2

#region window

var SCREEN_SIZE: Vector2 = DisplayServer.window_get_size()
#var MAP_CENTER: Vector2 = Vector2(SCREEN_SIZE[0]/2, SCREEN_SIZE[1]/2)

var LEFT_PANEL_SIZE = Vector2(SCREEN_SIZE[0]/4, SCREEN_SIZE[1])
var LEFT_PANEL_LOCATION = Vector2.ZERO

var CENTER_PANEL_SIZE = Vector2(SCREEN_SIZE[0]/2, SCREEN_SIZE[1]) # map
var CENTER_PANEL_LOCATION = Vector2(LEFT_PANEL_LOCATION[0] + LEFT_PANEL_SIZE[0], SCREEN_SIZE[1])

var RIGHT_PANEL_SIZE = Vector2(SCREEN_SIZE[0]/4, SCREEN_SIZE[1]/2)
var RIGHT_PANEL_LOCATION = Vector2(CENTER_PANEL_LOCATION[0] + CENTER_PANEL_SIZE[0], SCREEN_SIZE[1])

#endregion window


#region map
var MAP_CENTER = Vector2(CENTER_PANEL_SIZE[0]/2 + CENTER_PANEL_LOCATION[0], CENTER_PANEL_LOCATION[1]/2)

var NUM_X_TILES = int(CENTER_PANEL_SIZE[0] / TILE_SIZE) # num tiles across in x direction
var NUM_Y_TILES = int(CENTER_PANEL_SIZE[1] / TILE_SIZE) # num tiles across in y direction


#endregion map





#region colors
'''
var COLOR1: Color = Color.html("#804674")
var COLOR2: Color = Color.html("#A86464")
var COLOR3: Color = Color.html("#B3E5BE")
var COLOR4: Color = Color.html("#F5FFC9")
var COLOR5: Color = Color.html("#5798cc")
'''
'''
var COLOR1: Color = Color.html("#5FAAAF")
var COLOR2: Color = Color.html("#784D9E")
var COLOR3: Color = Color.html("#F4B942")
var COLOR4: Color = Color.html("#9195D4")
var COLOR5: Color = Color.html("#F3DE8A")
'''
'''
var COLOR_LIST: Array[String] = [
	"#ffd1dc",
	"#e9b6ac",
	"#c4a280",
	"#939160",
	"#5a7f54",
	"#006b57"
]
'''
'''
var COLOR_LIST: Array[String] = [
	"#ffd1dc",
	"#d5b2c7",
	"#a996b0",
	"#7d7b95",
	"#546178",
	"#2f4858"
]
'''

var COLOR_LIST: Array[String] = [
	"#ffd1dc",
	"#43212B",
	"#D2C6A5",
	"#2F4858",
	#"#83AFA1"
	"#82d6bb"
]


#endregion colors


#endregion

#region needs
const SET_RATES= {
	"MINUTE_5": 18.519, # refreshes in 5 minutes
	"HOUR_HALF": 3.333, # refreshes in 30 minutes
	"HOUR_1": 1.667, # refreshes in 1 hour
	"HOUR_4": 0.417, #refreshes in ??
	"HOUR_8": 0.203, # refreshes in 8 hours
	"HOUR_12": 0.139, # decays to 0 in 12 hours
	"DAY_1": 0.069, # decays to 0 in 1 day
	"DAY_2": 0.035, # decays to 0 in 2 days
	"DAY_3": 0.023, # decays to 0 in 3 days
	"WEEK_1": 0.001, # decays to 0 in 1 week
}


const NEED_DECAY_RATES= {
	"energy": SET_RATES["DAY_1"],
	"hunger": SET_RATES["HOUR_12"],
	"thirst": SET_RATES["HOUR_8"],
	"social": SET_RATES["DAY_1"],
	"release": SET_RATES["DAY_3"],
	"bladder": SET_RATES["HOUR_4"],
	"fun": SET_RATES["HOUR_8"],
	"work": SET_RATES["DAY_1"],
	"leisure": SET_RATES["DAY_1"],
	"shopping": SET_RATES["DAY_1"],
	"arousal": 0
}

const NEED_REFRESH_RATES = {
	"hunger" : SET_RATES["HOUR_1"],
	"energy" : SET_RATES["HOUR_8"],
	"social" : SET_RATES["HOUR_1"],
	"release" : SET_RATES["HOUR_HALF"], # not sure if i can make the encounter simulation run believably for an hour lol
	"work" : SET_RATES["HOUR_8"],
	"leisure" : SET_RATES["HOUR_1"],
	"shopping" : SET_RATES["HOUR_1"],
	"bladder": SET_RATES["MINUTE_5"],
	"fun": SET_RATES["HOUR_1"],
	"arousal": SET_RATES["HOUR_HALF"]
}
#endregions

var PORTRAIT_TEMPLATES = {
	"hair": [
		"res://models/portrait/hair/curly_long.png",
		"res://models/portrait/hair/high_ponytail.png",
		"res://models/portrait/hair/low_ponytail.png",
		"res://models/portrait/hair/straight_long.png",
		"res://models/portrait/hair/wavy_long.png",
	],
	"ears": [
		"res://models/portrait/ears/bunny.png",
		"res://models/portrait/ears/cat.png",
		"res://models/portrait/ears/dog.png",
		"res://models/portrait/ears/human.png",
	],
	"body": [
		"res://models/portrait/body/round.png",
		"res://models/portrait/body/round_square.png",
		"res://models/portrait/body/square.png",
	],
	"eyes": [
		"res://models/portrait/eyes/circle.png",
		"res://models/portrait/eyes/generic.png",
		"res://models/portrait/eyes/pointed.png",
	],
	
	
	"mouth": [
		"res://models/portrait/mouth/open.png",
		"res://models/portrait/mouth/smile.png",
	],
	"nose": [
		"res://models/portrait/nose/button.png",
		"res://models/portrait/nose/generic.png",
		"res://models/portrait/nose/strong.png",
	],
	"bangs" : [
		"res://models/portrait/bangs/curly.png",
		"res://models/portrait/bangs/long_fringe.png",
		"res://models/portrait/bangs/pulled_back.png",
		"res://models/portrait/bangs/straight.png",
		"res://models/portrait/bangs/wavy.png",
	],
	
	
}

var CLASS_TEMPLATES = {
	"GenericAction": ACTION,
	#"TileAction": TileAction,
	"SocialAction": SocialAction,
	"SeduceAction": SeduceAction
}

var ACTION_ID: Dictionary = {
	"IdleAction": IdleAction,
	"SocialAction": SocialAction,
	"SeduceAction": SeduceAction,
	"HungerAction": HungerAction,
	"BladderAction": BladderAction,
	"MoveAction": MoveAction,
	"DanceAction": DanceAction,
	"DrinkAction": DrinkAction
}


#region action templates
const ACTION_TEMPLATES = {
	"idle": {
		"need": "",
		"duration": 0,
		"pose": "standing",
		"joinable": true,
		"other_req": false,
		"do_off_tile": false,
		"class": "IdleAction"
	},
	"move": {
		"need": "",
		"duration": 3,
		"pose": "standing",
		"joinable": false,
		"other_req": false,
		"do_off_tile": false,
		"class": "MoveAction"
	},
	#region SocialAction
	"converse": {
		"need": "social",
		#"relationship": "friendship",
		"duration": 10,
		"followers": [1,4],
		"pose": "standing",
		"joinable": true,
		"other_req": true,
		"do_off_tile": true,
		"class": "SocialAction"
	},
	"encounter": {
		"need": "release",
		"duration": 30,
		"followers": [1,1],
		"pose": "standing",
		"joinable": false,
		"other_req": true,
		"do_off_tile": true,
		"conversable": false,
		"class": "SocialAction" # LOL i'll figure this out later
	},
	"flirt": {
		"need": "social",
		"duration": 5,
		"followers": [1,1],
		"pose": "standing",
		"joinable": false,
		"other_req": true,
		"do_off_tile": true,
		"conversable": false,
		"class": "SocialAction"
	},
	"seduce": {
		"need": "release",
		"duration": 5,
		"followers": [1,1],
		"pose": "standing",
		"joinable": false,
		"other_req": true,
		"do_off_tile": true,
		"conversable": false,
		"class": "SeduceAction"
	},
	#region TileAction
	"loiter": {
		"need": "social",
		"duration": 10,
		"joinable": true,
		"other_req": false,
		"do_off_tile": true,
		"class": "SocialAction"
	},
	"dance" : {
		"need": "fun",
		"duration": 10,
		"followers": [0,3],
		"pose": "standing",
		"joinable": true,
		"other_req": false,
		"do_off_tile": false,
		"conversable": false,
		"class": "DanceAction"
	},
	"drink": {
		"need": "fun",
		"duration": 5,
		"followers": [0,0],
		"pose": "standing",
		"joinable": false,
		"other_req": false,
		"do_off_tile": true,
		"class": "DrinkAction"
	},
	"use toilet": {
		"need": "bladder",
		"duration": 5,
		"followers": [0,0],
		"pose": "standing",
		"joinable": false,
		"other_req": false,
		"do_off_tile": false,
		"conversable": false,
		"class": "BladderAction"
	},
	"bladder": {
		"need": "bladder",
		"duration": 5,
		"followers": [0,0],
		"pose": "standing",
		"joinable": false,
		"other_req": false,
		"do_off_tile": false,
		"conversable": false,
		"class": "BladderAction"
	},
	"snack": {
		"duration": 5,
		"followers": [0,0],
		"pose": "standing",
		"joinable": false,
		"other_req": false,
		"do_off_tile": true,
		"class": "HungerAction"
	},
	"hunger": {
		"duration": 5,
		"followers": [0,0],
		"pose": "standing",
		"joinable": false,
		"other_req": false,
		"do_off_tile": true,
		"class": "HungerAction"
	}
}

#endregion

#region tiles

const POSE_CLASS = {
	#"EmptyPoses": ["standing", "kneeling", "laying"],
	"EmptyPoses": ["standing"],
	"ChairPoses": ["sitting"],
	"HSurfacePoses": ["standing"],
	"VSurfacePoses": ["standing"]
}
const TILE_TEMPLATES = {
	"empty": {
		"actions": [],
		"impassable": false,
		"png": "tile.png",
		"poses": "EmptyPoses"
	},
	"social_empty": {
		"actions": [],
		"impassable": false,
		"png": "tile.png",
		"poses": "EmptyPoses"
	},
	"dance_floor": {
		"actions": ["dance"],
		"impassable": false,
		"png": "dance_floor.png",
		"poses": "EmptyPoses"
	},
	"toilet":  {
		"actions": ["use toilet", "bladder"],
		"impassable": false,
		"encounter_location": true,
		"png": "toilet.png",
		"poses": "ChairPoses"
	},
	"bar": {
		"actions": ["drink", "snack", "hunger"],
		"impassable": true,
		"png": "bar.png",
		"poses": "HSurfacePoses"
	},
	"table": {
		"actions": [],
		"impassable": true,
		"png": "table.png",
		"poses": "HSurfacePoses"
	},
	"wall": {
		"actions": [],
		"impassable": true,
		"png": "wall.png",
		"poses": "VSurfacePoses"
	}

}


#endregion
