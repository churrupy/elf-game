extends ColorRect

class_name Map

var MAP = []
var X_RANGE
var Y_RANGE
var ROOM = "club"
@export var tile_scene: PackedScene

var MAP_TEMPLATES = {
"club": {
		"default": "social_empty",
		"size": [3,3],
		"special": {
			[1,1]: "dance_floor",
			[1,2]: "dance_floor",
			[1,3]: "bar",
			[2,1]: "dance_floor",
			[2,2]: "dance_floor",
			[2,3]: "bar",
			[3,0]: "standing_table",
			[3,1]: "bathroom",
			[3,2]: "bathroom",
		},
		"ascii": '''
[S][S][S][S]
[S][D][D][B]
[S][D][D][B]
[S][S][B][B]
	'''
	}

}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$Grid.hide()			
	size = Constants.MAIN_FRAME_SIZE
	position = Constants.MAIN_FRAME_POSITION
	var room_data = MAP_TEMPLATES[ROOM]
	var special_tiles = room_data["special"]
	for i in Constants.MAP_SIZE[0]:
		MAP.append([])
		for j in Constants.MAP_SIZE[1]:
			var tile = tile_scene.instantiate()
			tile.hide()
			MAP[i].append(tile)
			add_child(tile)
			var location = [i,j]
			tile.LOCATION = location
			if location in special_tiles.keys():
				var type = special_tiles[location]
				tile.TYPE = type
			else:
				var type = room_data["default"]
				tile.TYPE = type
			tile.initialize()

		



func hide_all_tiles():
	for child in get_children():
		if child is Tile:
			child.hide()


func tick():
	hide_all_tiles()
	X_RANGE = [Global.PLAYER_LOCATION[0] - 7, Global.PLAYER_LOCATION[0] + 8]
	Y_RANGE = [Global.PLAYER_LOCATION[1] - 5, Global.PLAYER_LOCATION[1] + 6]
	var x_counter = Constants.MAIN_FRAME_POSITION[0]
	var y_counter = 0

	for x in range(X_RANGE[0], X_RANGE[1]):
		if x not in range(0, len(MAP)):
			x_counter += Constants.TILE_SIZE
			y_counter = 0
			continue
		for y in range(Y_RANGE[0], Y_RANGE[1]):
			if y not in range(0, len(MAP[0])):
				y_counter += Constants.TILE_SIZE
				continue
			var tile = MAP[x][y]
			#print("showing", x, y)
			tile.global_position = Vector2(x_counter, y_counter)
			tile.show()
			y_counter += Constants.TILE_SIZE
		x_counter += Constants.TILE_SIZE
		y_counter = 0


#region utility

func free_tile(location: Array):
	var tile = get_tile(location)
	tile.OCCUPANT = null
	tile.RESERVED = null

func reserve_tile(location, npc):
	var tile = get_tile(location)
	tile.RESERVED = npc

func occupy_tile(occupant):
	var location = occupant.LOCATION
	MAP[location[0]][location[1]].OCCUPANT = occupant

func get_tile(location: Array):
	return MAP[location[0]][location[1]]

func random_tile():
	var x = randi_range(0, Constants.MAP_SIZE[0]-1)
	var y = randi_range(0, Constants.MAP_SIZE[1]-1)
	return MAP[x][y]

func get_all_actions_on_map():
	var all_actions = []
	for i in len(MAP):
		for j in len(MAP[0]):
			var tile = MAP[i][j]
			var type_actions = Constants.TILE_TEMPLATES[tile.TYPE]["actions"]
			for action in type_actions:
				var new_action = ACTIONS.new()
				new_action.ID = action
				new_action.TARGET = tile
				new_action.LOCATION = tile.LOCATION
				var action_data = Constants.ACTION_TEMPLATES[action]
				new_action.NEED = action_data["need"]
				all_actions.append(new_action)
	return all_actions


#endregion
