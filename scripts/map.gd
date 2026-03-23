extends ColorRect

class_name Map

var MAP = []
var ROOM = "club"
@export var tile_scene: PackedScene

var MAP_TEMPLATES = {
"club": {
		"default": "empty",
		"size": [3,3],
		"special": {
			[0,0]: "social_empty",
			[0,2]: "social_empty",
			[0,4]: "social_empty",
			[1,8]: "table",
			[2,1]: "dance_floor",
			[2,3]: "dance_floor",
			[2,5]: "dance_floor",
			[2,8]: "table",
			[4,1]: "dance_floor",
			[4,3]: "dance_floor",
			[4,5]: "dance_floor",
			[5,8]: "bar",
			[6,0]: "wall",
			[6,1]: "wall",
			[6,2]: "wall",
			[6,3]: "wall",
			[6,4]: "wall",
			[6,5]: "wall",
			[6,8]: "bar",
			[7,8]: "bar",
			[8,1]: "wall",
			[8,3]: "wall",
			[8,5]: "wall",
			[8,8]: "bar",
			[9,0]: "toilet",
			[9,1]: "wall",
			[9,2]: "toilet",
			[9,3]: "wall",
			[9,4]: "toilet",
			[9,5]: "wall",
			[9,8]: "bar"
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

		
func get_tile_list():
	var tile_list = []
	for i in len(MAP):
		for j in len(MAP[0]):
			var tile = MAP[i][j]
			tile_list.append(tile)
	return tile_list


func hide_all_tiles():
	for child in get_children():
		if child is Tile:
			child.hide()


func tick():
	hide_all_tiles()
	var x_counter = Constants.MAIN_FRAME_POSITION[0]
	var y_counter = 0

	for x in range(Global.X_RANGE[0], Global.X_RANGE[1]):
		if x not in range(0, len(MAP)):
			x_counter += Constants.TILE_SIZE
			y_counter = 0
			continue
		for y in range(Global.Y_RANGE[0], Global.Y_RANGE[1]):
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

func empty_tile(location: Array):
	var tile = get_tile(location)
	tile.OCCUPANT = null


func free_tile(location: Array):
	var tile = get_tile(location)
	tile.RESERVED = null

func reserve_tile(npc, location):
	var tile = get_tile(location)
	tile.RESERVED = npc

func swap_tile(npc, location):
	var new_tile = get_tile(location)
	var old_occupant = new_tile.OCCUPANT
	#old_occupant.LOCATION = [npc.LOCATION[0], npc.LOCATION[1]]
	#npc.LOCATION = location
	occupy_tile(old_occupant, npc.LOCATION)
	occupy_tile(npc, location)

func occupy_tile(npc, location):
	npc.LOCATION = location
	MAP[location[0]][location[1]].OCCUPANT = npc

func get_tile(location: Array):
	return MAP[location[0]][location[1]]

func random_empty_tile():
	while true:
		var location = [randi_range(0, Constants.MAP_SIZE[0]-1), randi_range(0, Constants.MAP_SIZE[1]-1)]
		var tile = get_tile(location)
		if !tile.is_reserved_or_occupied():
			return tile

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
