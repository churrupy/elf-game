extends ColorRect

class_name MAP

var ENGINE
var TILES: Array[TILE]
var ROOM: String
@export var tile_scene: PackedScene

var TILES_TEMPLATES = {
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
	

func _init(engine, room) -> void:
	ENGINE = engine
	ROOM = room
	size = Constants.MAIN_FRAME_SIZE
	position = Constants.MAIN_FRAME_POSITION
	color = Color(.3, .3, .3)
	
	var room_data: Dictionary = TILES_TEMPLATES[ROOM]
	var special_tiles: Dictionary = room_data["special"]
	for i: int in Constants.MAP_SIZE[0]:
		for j: int in Constants.MAP_SIZE[1]:
			
			#tile.LOCATION = Vector2(i,j)
			var location = Vector2(i,j)
			var loc_array = [i,j]
			var type: String = room_data["default"]
			if loc_array in special_tiles.keys():
				type = special_tiles[loc_array]

			var tile: TILE = TILE.new(type, Vector2(i,j))
			TILES.append(tile)


func _ready_old() -> void:
	pass
	#$Grid.hide()
	'''
	size = Constants.MAIN_FRAME_SIZE
	position = Constants.MAIN_FRAME_POSITION
	var room_data: Dictionary = TILES_TEMPLATES[ROOM]
	var special_tiles: Dictionary = room_data["special"]
	for i: int in Constants.MAP_SIZE[0]:
		TILES.append([])
		for j: int in Constants.MAP_SIZE[1]:
			var location: Array = [i, j]
			var type: String = room_data["default"]
			if location in special_tiles.keys():
				type = special_tiles[location]
			TILES[i].append(type)
	'''



#region update

func clear_tiles():
	for child in get_children():
		if child is TILE:
			remove_child(child)

func update() -> void:
	clear_tiles()
	print(Global.X_RANGE)
	print(Global.Y_RANGE)
	for tile: TILE in TILES:
		#[var x: int, var y: int] = tile.LOCATION
		var x: int = tile.LOCATION[0]
		var y: int = tile.LOCATION[1]
		if x not in range(Global.X_RANGE[0], Global.X_RANGE[1]):
			continue;
		if y not in range(Global.Y_RANGE[0], Global.Y_RANGE[1]):
			continue
		
		add_child(tile)
		var x_index = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(x)
		var y_index = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(y)
		tile.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.MAIN_FRAME_POSITION[0]
		tile.global_position[1] = y_index * Constants.TILE_SIZE
		#tile.show()
			


func update_old():
	clear_tiles()
	for x in range (Global.X_RANGE[0], Global.X_RANGE[1]):
		if x not in range(0, len(TILES)):
			continue
		for y in range(Global.Y_RANGE[0], Global.Y_RANGE[1]):
			if y not in range(0, len(TILES[0])):
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

#endregion update

#region pathfinding

func step_towards_location(end: Vector2, start: Vector2) -> Vector2:
	#pathfinding
	if start == end:
		push_error("Trying to pathfind to current location")
		return start # shouldn't happen but who knows

	var queue: Array[Vector2] = [start]
	var visited: Array[Vector2] = [start]
	var parent_dict: Dictionary = {}

	var current: Vector2

	while len(queue) > 0:
		current = queue.pop_front()
		if current == end:
			return parent_dict[end]
		for neighbor in get_neighbors(current):
			if neighbor in visited:
				continue
			visited.append(neighbor)
			queue.append(neighbor)
			parent_dict[neighbor] = current
	push_error("pathfind fail")
	return Vector2.INF



# not used
func get_next_step(parent_dict: Dictionary, start: Vector2, end: Vector2) -> Vector2:
	var node: Vector2 = end
	while true:
		var parent = parent_dict[node] #not sure if i can use a list as a key in godot 
		if parent == start:
			return node
		node = parent
	return Vector2.INF



#endregion pathfinding


#region filters

func get_tiles_from_vector_list(vector_list: Array[Vector2]) -> Array[TILE]:
	if len(vector_list) == 0:
		return TILES
	var tile_list: Array[TILE]
	for v: Vector2 in vector_list:
		var tile: TILE = get_tile(v)
		tile_list.append(tile)
	return tile_list


func filter_passable_locations(vector_list: Array[Vector2] = []) -> Array[Vector2]:
	var tile_list: Array[TILE] = get_tiles_from_vector_list(vector_list)
	var passable_locations: Array[Vector2]
	for tile: TILE in tile_list:
		var tile_data: Dictionary = Constants.TILE_TEMPLATES[tile.TYPE]
		if tile_data["impassable"] == false:
			passable_locations.append(tile.LOCATION)
	return passable_locations



#endregion filters

#region checks

func is_impassable(location: Vector2) -> bool:
	var tile: TILE = get_tile(location)
	if tile == null:
		return true
	var tile_data: Dictionary = Constants.TILE_TEMPLATES[tile.TYPE]
	return tile_data["impassable"]




#endregion


#region utility

func get_neighbors(location: Vector2) -> Array[Vector2]:

	var neighbors: Array[Vector2] = [
		# adjacent
		location + Vector2(1,0),
		location + Vector2(-1,0),
		location + Vector2(0,1),
		location + Vector2(0,-1),
		# diaglonals
		location + Vector2(1,1),
		location + Vector2(1,-1),
		location + Vector2(-1,1),
		location + Vector2(-1,-1)
	]

	var valid_neighbors: Array[Vector2]
	for n: Vector2 in neighbors:
		if n[0] < 0 or n[0] >= Constants.MAP_SIZE[0]: continue
		if n[1] < 0 or n[1] >= Constants.MAP_SIZE[1]: continue
		if is_impassable(n): continue
		valid_neighbors.append(n)
	var passable_locations: Array[Vector2] = filter_passable_locations(valid_neighbors)
	return passable_locations


func get_neighbors_old(location: Array) -> Array:
	var neighbors: Array = [
		#[location[0], location[1]],
		# adjacent
		[location[0] + 1, location[1]],
		[location[0] - 1, location[1]],
		[location[0], location[1] + 1],
		[location[0], location[1] - 1],
		# diagonals
		[location[0] + 1, location[1] + 1],
		[location[0] + 1, location[1] - 1],
		[location[0] - 1, location[1] + 1],
		[location[0] - 1, location[1] - 1]
	]
	var valid_neighbors: Array = []
	for n: Vector2 in neighbors:
		if n[0] < 0 or n[0] >= Constants.MAP_SIZE[0]:
			continue
		if n[1] < 0 or n[1] >= Constants.MAP_SIZE[1]:
			continue
		if is_impassable(n): continue
		valid_neighbors.append(n)
		
	return valid_neighbors

func get_closest_adjacent_location(start_location: Vector2, target_location: Vector2) -> Vector2:
	# gets tile adjacent to target that's closest to start location
	var neighbors: Array[Vector2] = get_neighbors(target_location)
	if start_location in neighbors:
		return start_location
	
	var free_neighbors: Array[Vector2] = ENGINE.NpcManager.filter_reserved_locations(neighbors)

	if len(free_neighbors) == 0:
		print("no free adjacent tiles found")
		return Vector2.INF
	
	var smallest_distance: float = 100
	var closest_tile: Vector2
	for v: Vector2 in free_neighbors:
		var distance: float = start_location.distance_to(v)
		if distance < smallest_distance:
			smallest_distance = distance
			closest_tile = v
	return closest_tile




func get_tile(location: Vector2) -> TILE:
	for tile: TILE in TILES:
		if tile.LOCATION == location:
			return tile
	return null

func get_tile_old(location: Array):
	if location[0] not in range(len(TILES)): return null
	if location[1] not in range(len(TILES[0])): return null
	return TILES[location[0]][location[1]]

'''
func random_empty_tile_old() -> Array:
	while true:
		var x = randi_range(0, Constants.MAP_SIZE[0]-1) 
		var y = randi_range(0, Constants.MAP_SIZE[1]-1)
		var tile = TILES[x][y]
		var tile_data = Constants.TILE_TEMPLATES[tile]
		if tile_data["impassable"] == false:
			return [x,y]
	return []
'''
	
func random_empty_tile() -> TILE:
	for tile:TILE in TILES:
		var tile_data: Dictionary = Constants.TILE_TEMPLATES[tile.TYPE]
		if tile_data["impassable"] == false: return tile
	return null

func find_action_locations(action:String) -> Array[Vector2]:
	if action == "encounter":
		return find_encounter_locations()
	var filtered_locations: Array[Vector2] = []
	for tile: TILE in TILES:
		var tile_data: Dictionary = Constants.TILE_TEMPLATES[tile.TYPE]
		if action in tile_data["actions"]:
			filtered_locations.append(tile.LOCATION)
	return filtered_locations


func find_encounter_locations() -> Array[Vector2]:
	var encounter_locations: Array[Vector2]
	for tile:TILE in TILES:
		var tile_data: Dictionary = Constants.TILE_TEMPLATES[tile.TYPE]
		if "encounter_location" in tile_data.keys():
			encounter_locations.append(tile.LOCATION)
	return encounter_locations



func get_all_actions_on_map(npc) -> Array[ACTION]:
	var all_actions: Array[ACTION]
	for tile: TILE in TILES:
		var tile_data: Dictionary = Constants.TILE_TEMPLATES[tile.TYPE]
		for action: String in tile_data["actions"]:
			var action_class_id: String = Constants.ACTION_TEMPLATES[action]["class"]
			var ACTION_CLASS: GDScript = Constants.ACTION_ID[action_class_id]
			var new_action: ACTION = ACTION_CLASS.new(ENGINE, npc, tile)
			all_actions.append(new_action)
	return all_actions
'''
func get_all_actions_on_map_old():
	var all_actions = []
	for i in len(TILES):
		for j in len(TILES[0]):
			var tile = TILES[i][j]
			var tile_data = Constants.TILE_TEMPLATES[tile]
			for action in tile_data["actions"]:
				var action_data: Dictionary = Constants.ACTION_TEMPLATES[action]
				var action_class_id: String = action_data["class"]
				var action_class: GDScript = Constants.CLASS_TEMPLATES[action_class_id]
				var new_action: GenericAction  = action_class.new(ENGINE, action)
				#new_action.TARGET = [i,j] # where the npc wants to pathfind to
				new_action.LOCATION = [i,j] # where the npc ends up (if adjacent to target)
				all_actions.append(new_action)
	return all_actions
'''

func get_available_poses_for_tile(location: Vector2) -> Array[String]:
	var tile: TILE = get_tile(location)
	var pose_class: String = Constants.TILE_TEMPLATES[tile.TYPE]["poses"]
	return Constants.POSE_CLASS[pose_class]


		

#endregion utility
