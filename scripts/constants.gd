extends Node

#region game const
const TILE_SIZE = 60
const SCREEN_SIZE = Vector2(1200, 660)
const MAP_SIZE = [10,10] # num tiles across
const BOTTOM_RIGHT = Vector2(MAP_SIZE[0]-1, MAP_SIZE[1]-1)
const NUM_NPCS = 5
const SIDEBAR_SIZE = Vector2(300, SCREEN_SIZE[1])
const MAIN_FRAME_SIZE = Vector2(SCREEN_SIZE[0] - SIDEBAR_SIZE[0], SCREEN_SIZE[1])
const MAIN_FRAME_POSITION = Vector2(SIDEBAR_SIZE[0], 0)

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
	"fun": SET_RATES["HOUR_1"]
}
#endregions

var CLASS_TEMPLATES = {
	"GenericAction": GenericAction,
	"TileAction": TileAction,
	"SocialAction": SocialAction
}


#region action templates
const ACTION_TEMPLATES = {
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
		"joinable": true,
		"other_req": true,
		"do_off_tile": true,
		"conversable": false,
		"class": "GenericAction"
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
	#region TileAction
	"loiter": {
		"need": "social",
		"duration": 10,
		"joinable": true,
		"other_req": false,
		"do_off_tile": true,
		"class": "TileAction"
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
		"class": "TileAction"
	},
	"drink": {
		"need": "fun",
		"duration": 5,
		"followers": [0,0],
		"pose": "standing",
		"joinable": false,
		"other_req": false,
		"do_off_tile": true,
		"class": "TileAction"
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
		"class": "TileAction"
	},
	"snack": {
		"need": "hunger",
		"duration": 5,
		"followers": [0,0],
		"pose": "standing",
		"joinable": false,
		"other_req": false,
		"do_off_tile": true,
		"class": "TileAction"
	},
	"follow": {
		"need": "none",
		"duration": 0,
		"followers": [0,0],
		"pose": "standing",
		"joinable": true,
		"other_req": true,
		"do_off_tile": true,
		"class": "GenericAction"
	}
}

#endregion

#region tiles
const TILE_TEMPLATES = {
	"empty": {
		"actions": ["loiter"],
		"impassable": false,
		"png": "tile.png"
	},
	"social_empty": {
		"actions": ["loiter"],
		"impassable": false,
		"png": "tile.png"
	},
	"dance_floor": {
		"actions": ["dance"],
		"impassable": false,
		"png": "dance_floor.png"
	},
	"toilet":  {
		"actions": ["use toilet", "loiter", "encounter"],
		"impassable": false,
		"png": "toilet.png"
	},
	"bar": {
		"actions": ["loiter", "snack"],
		"impassable": true,
		"png": "bar.png"
	},
	"table": {
		"actions": ["loiter"],
		"impassable": true,
		"png": "table.png"
	},
	"wall": {
		"actions": [],
		"impassable": true,
		"png": "wall.png"
	}

}


#endregion
