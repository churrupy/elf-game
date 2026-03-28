extends ColorRect

class_name Map

var ENGINE
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


func _ready() -> void:
	#$Grid.hide()			
	size = Constants.MAIN_FRAME_SIZE
	position = Constants.MAIN_FRAME_POSITION
	var room_data = MAP_TEMPLATES[ROOM]
	var special_tiles = room_data["special"]
	for i in Constants.MAP_SIZE[0]:
		MAP.append([])
		for j in Constants.MAP_SIZE[1]:
			var location = [i, j]
			var type = room_data["default"]
			if location in special_tiles.keys():
				type = special_tiles[location]
			MAP[i].append(type)

		
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

func clear_tiles():
	for child in get_children():
		if child is Tile:
			child.queue_free()

func update():
	clear_tiles()
	for x in range (Global.X_RANGE[0], Global.X_RANGE[1]):
		if x not in range(0, len(MAP)):
			continue
		for y in range(Global.Y_RANGE[0], Global.Y_RANGE[1]):
			if y not in range(0, len(MAP[0])):
				continue
			var x_index = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(x)
			if x_index < 0:
				continue
			var y_index = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(y)
			if y_index < 0:
				continue
			var location = [x, y]
			var tile_type = get_tile(location)
			if tile_type == null: continue
			var tile = tile_scene.instantiate()
			tile.initialize(tile_type, location)
			add_child(tile)
			tile.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.MAIN_FRAME_POSITION[0]
			tile.global_position[1] = y_index * Constants.TILE_SIZE
			tile.show()

func update_old():
	clear_tiles()

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
			var location = [x, y]
			var tile_type = get_tile(location)
			var tile = tile_scene.instantiate()
			tile.initialize(tile_type, location)
			add_child(tile)
			tile.global_position = Vector2(x_counter, y_counter)
			tile.show()
			y_counter += Constants.TILE_SIZE
		x_counter += Constants.TILE_SIZE
		y_counter = 0

func is_travelable(location):
	var tile = get_tile(location)
	var tile_data = Constants.TILE_TEMPLATES[tile]
	if tile_data["impassable"] == true: return false
	return true


#region utility


func get_tile(location: Array):
	if location[0] not in range(len(MAP)): return null
	if location[1] not in range(len(MAP[0])): return null
	return MAP[location[0]][location[1]]

func random_empty_tile():
	while true:
		var x = randi_range(0, Constants.MAP_SIZE[0]-1) 
		var y = randi_range(0, Constants.MAP_SIZE[1]-1)
		var tile = MAP[x][y]
		var tile_data = Constants.TILE_TEMPLATES[tile]
		if tile_data["impassable"] == false:
			return [x,y]

func find_action_locations(action):
	var filtered_locations = []
	for i in len(MAP):
		for j in len(MAP[0]):
			var location = [i,j]
			var tile = get_tile(location)
			var tile_data = Constants.TILE_TEMPLATES[tile]
			if action in tile_data["actions"]:
				filtered_locations.append(location)

	return filtered_locations




func get_all_actions_on_map():
	var all_actions = []
	for i in len(MAP):
		for j in len(MAP[0]):
			var tile = MAP[i][j]
			var tile_data = Constants.TILE_TEMPLATES[tile]
			for action in tile_data["actions"]:
				var action_data = Constants.ACTION_TEMPLATES[action]
				var action_class_id = action_data["class"]
				var action_class = Constants.CLASS_TEMPLATES[action_class_id]
				var new_action  = action_class.new(ENGINE, action)
				new_action.TARGET = [i,j] # where the npc wants to pathfind to
				new_action.LOCATION = [i,j] # where the npc ends up (if adjacent to target)
				all_actions.append(new_action)
	return all_actions

func get_available_poses_for_tile(location):
	var tile = get_tile(location)
	var pose_class = Constants.TILE_TEMPLATES[tile]["poses"]
	return Constants.POSE_CLASS[pose_class]


		

#endregion
