extends Node

#region game const
const TILE_SIZE = 64
#const SCREEN_SIZE = Vector2(1200, 660)
const MAP_SIZE = [11,10] # num tiles across
const BOTTOM_RIGHT = Vector2(MAP_SIZE[0]-1, MAP_SIZE[1]-1)
const NUM_NPCS = 5

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

#region tiles

const POSE_CLASS = {
	#"EmptyPoses": ["standing", "kneeling", "laying"],
	"EmptyPoses": ["standing"],
	"ChairPoses": ["sitting"],
	"HSurfacePoses": ["standing"],
	"VSurfacePoses": ["standing"]
}


const TILE_TEMPLATES:Dictionary = {
	"empty": {
		"tags": ["floor", "only_on"],
		"sprite": "tile.png",
		"interactable_range": [0,0]
	},
	"counter": {
		"tags": ["h_surface", "only_adjacent"],
		"sprite": "bar.png",
		"may_contain": [
			"snack",
			"beer"
		],
		"interactable_range": [0.1,1.5]
	},
	"dance_floor": {
		"tags": ["floor", "only_on"],
		"sprite": "dance_floor.png",
		"interactable_range": [0,0],
		"refreshes": "fun"
	},
	"door": {
		"tags": ["door", "only_on"],
		"sprite": "door_top.png",
		"interactable_range": [0,0]
	},
	"kitchen_counter": {
		"tags": ["h_surface", "only_adjacent"],
		"sprite": "bar.png",
		"contains": [
			"clean water",
			"wheat flour",
			"metal bowl"
		],
		"interactable_range": [0.1,1.5]
	},
	"oven": {
		"tags": ["oven", "only_adjacent"],
		"sprite": "oven.png",
		"interactable_range": [0.1,1.5]
	},
	"table": {
		"tags": ["h_surface", "only_adjacent"],
		"sprite": "table.png",
		"interactable_range": [0.1,1.5]
	},
	"toilet":  {
		"tags": ["chair", "fill_bladder", "encounter_location", "only_on"],
		"sprite": "toilet.png",
		"refreshes": "bladder",
		"private": true,
		"interactable_range": [0,0]
	},	
	"wall": {
		"tags": ["v_surface", "only_adjacent"],
		"sprite": "wall.png",
		"interactable_range": [0.1,1.5]
	}
}


#endregion



#region items
var ITEM_TEMPLATES: Dictionary = {
	"beer": {
		"description": "Let's get smashed!",
		"nutrition": 5,
		"tags": ["alcohol"],
		"refreshes": "fun"
	},
	"bread": {
		"description": "Nice crusty bread.",
		"nutrition": 20,
		"tags": ["food"],
		"refreshes": "hunger"
	},
	"dough": {
		"description": "Soft pillowy dough for making bread.",
		"nutrition": 0,
		"tags": ["cooking_ingredient", "dough"]
	},
	"clean water": {
		"description": "Fresh clean water",
		"nutrition": 0,
		"tags": ["cooking_ingredient", "water"]
	},
	"metal bowl": {
		"description": "Metal bowl good for mixing ingredients in.",
		"nutrition": 0,
		"tags": ["tool", "bowl"]
	},
	"snack" : {
		"description": "Freedom fries! *bird noises*",
		"nutrition": 20,
		"tags": ["food"],
		"refreshes": "hunger"
	},
	
	"wheat flour": {
		"description": "Fine powder, but not the kind you snort.",
		"nutrition": 5,
		"tags": ["cooking_ingredient", "flour"]
	},
	
	
}

#FoodManager
#AlcoholManager

#endregion items
