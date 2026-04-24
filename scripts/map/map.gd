class_name MAP extends ColorRect

var ENGINE
var TILES: Array[TILE]
var FURNITURE: Array[Furniture]
var ROOM: String

@export var tile_scene: PackedScene
	
#region init

func _init(engine, room) -> void:
	ENGINE = engine
	ROOM = room
	#size = Global.MAIN_FRAME_SIZE
	#position = Constants.MAIN_FRAME_POSITION
	color = Color(.3, .3, .3)
	size = Constants.CENTER_PANEL_SIZE
	global_position = Constants.CENTER_PANEL_LOCATION

	# var map_size: int = Constants.MAP_SIZE[0] * Constants.MAP_SIZE[1]
	# var room_data: Dictionary = Rooms.TILES_TEMPLATES[ROOM]
	# var default_type: String = room_data["default"]

	# var width: int = Constants.MAP_SIZE[0]

	var room_data: Dictionary = Rooms.ROOM_TEMPLATES[ROOM]
	var room_size: Vector2 = room_data["size"]
	var room_area: int = room_size[0] * room_size[1]

	var width:int = room_size[0]

	for i in range(0,room_area):
		var x:int = i%width
		var y:int = i/width
		var location: Vector2 = Vector2(x,y)
		var tile:TILE = TILE.new("empty", location)
		TILES.append(tile)
		ENGINE.InventoryManager.create_inventory(tile)

	for keyword: String in room_data["furniture"].keys():
		var furniture_data: Array = room_data["furniture"][keyword]
		for rect: Array in furniture_data:
			var start_vector: Vector2 = rect[0]
			var end_vector: Vector2 = rect[1]
			for i in range(int(start_vector[0]), int(end_vector[0])+1):
				for j in range(int(start_vector[1]), int(end_vector[1])+1):
					var loc: Vector2 = Vector2(i,j)
					var new_furniture: Furniture = Furniture.new(keyword, loc)
					FURNITURE.append(new_furniture)
					if "container" in new_furniture.DATA["tags"]:
						ENGINE.InventoryManager.create_inventory(new_furniture)
						var tile: TILE = get_tile(loc)
						ENGINE.InventoryManager.remove_inventory(tile) # i'll try to figure out a better way to do this
						for item_type: String in new_furniture.DATA["may_contain"]:
							var amount:int = [0,1,2,3].pick_random()
							for k in range(0,amount + 1):
								var new_item:ITEM = ITEM.new(item_type)
								ENGINE.InventoryManager.add_to_inventory(new_furniture, new_item)

					


	# for loc: Array in room_data["special"]:
	# 	var type: String = room_data["special"][loc]
	# 	var index = (loc[1] * width) + loc[0]
	# 	TILES[index].TYPE = type
	# 	TILES[index].initialize()


#endregion init

#region update

func clear_tiles():
	for child in get_children():
		if child is TILE or child is Furniture:
			remove_child(child)

func update() -> void:
	clear_tiles()
	for tile: TILE in TILES:
		#[var x: int, var y: int] = tile.LOCATION

		var screen_index: Vector2 = ENGINE.get_screen_index(tile.LOCATION)
		if screen_index[0] < 0 or screen_index[1] < 0:
			continue
		
		add_child(tile)
		
		tile.global_position[0] = (screen_index[0] * Constants.TILE_SIZE) + Constants.CENTER_PANEL_LOCATION[0]
		tile.global_position[1] = screen_index[1] * Constants.TILE_SIZE
		
		if is_in_line_of_sight(ENGINE.get_node("Player").LOCATION, tile.LOCATION):
			#print(ENGINE.prettify_vector(tile.LOCATION), " is in line of sight")
			tile.modulate = Color(1,1,0)
		else: 
			tile.modulate = Color(1,1,1)
		
		
		# var x_index = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(x)
		# var y_index = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(y)
		# tile.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.CENTER_PANEL_LOCATION[0]
		# tile.global_position[1] = y_index * Constants.TILE_SIZE
		
		

		#tile.show()

	for furniture: Furniture in FURNITURE:
		var screen_index: Vector2 = ENGINE.get_screen_index(furniture.LOCATION)

		if screen_index[0] < 0 or screen_index[1] < 0:
			continue
		
		add_child(furniture)

		furniture.global_position[0] = (screen_index[0] * Constants.TILE_SIZE) + Constants.CENTER_PANEL_LOCATION[0]
		furniture.global_position[1] = screen_index[1] * Constants.TILE_SIZE
			


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


#region raypath

func get_ray_path(origin: Vector2, target: Vector2) -> Array[Vector2]:
	# gets all nodes between origin and target
	var ray_path: Array[Vector2] = [origin]
	var next_step: Vector2 = origin
	var direction: Vector2 = origin.direction_to(target)
	var y_sign: int = 1 if direction[1] >= 0 else -1
	var x_sign: int = 1 if direction[0] >= 0 else -1
	var distBtRow: float = 1/(abs(origin[1] - target[1]))
	var distBtCol: float = 1/(abs(origin[0] - target[0]))
	var distToY: float = distBtRow
	var distToX: float = distBtCol
	for i in range (0, 100):
		if next_step == target: break
		#print(ENGINE.prettify_vector(next_step))
		if distToY <= distToX: 
			# steeper line, moving either up/down
			next_step[1] += 1 * y_sign
			ray_path.append(next_step)
			distToY += distBtRow
		else:
			# shallower line, moving either left/right
			next_step[0] += 1 * x_sign
			ray_path.append(next_step)
			distToX += distBtCol
	return ray_path

func is_in_line_of_sight(origin: Vector2, target:Vector2) -> bool:
	if int(target[0]) not in range(0, Constants.MAP_SIZE[0]) or int(target[1]) not in range(0, Constants.MAP_SIZE[1]):
		return false
	var ray_path: Array[Vector2] = get_ray_path(origin, target)
	for v: Vector2 in ray_path:
		if !is_loc_visible(v):
			return false
		# var tile:TILE = get_tile(v)
		# if tile.TYPE == "wall":
		# 	return false
	return true

#endregion raypath


# func filter_loc_in_direction(origin:Vector2, direction:Vector2) -> Array[Vector2]:
# 	var filtered_loc: Array[Vector2]
# 	for tile: TILE in TILES:
# 		var checked_direction: Vector2 = origin.direction_to(tile.LOCATION)
# 		if checked_direction == direction:
# 			filtered_loc.append(tile.LOCATION)
# 	return filtered_loc

#region filters

func is_passable(loc: Vector2) -> bool:
	for furniture: Furniture in FURNITURE:
		if furniture.LOCATION == loc:
			var type: String = furniture.DATA["type"]
			if "surface" in type: # h_surfance and v_surface are impassable
				return false

	return true

func is_loc_visible(loc: Vector2) -> bool:
	for furniture: Furniture in FURNITURE:
		if furniture.LOCATION == loc:
			var type: String = furniture.DATA["type"]
			if type == "v_surface":
				return false
	return true

func filter_passable_locations(v_list: Array[Vector2] = get_all_locations()) -> Array[Vector2]:
	var passable_loc: Array[Vector2]
	for v: Vector2 in v_list:
		if is_passable(v):
			passable_loc.append(v)
	return passable_loc

func get_all_locations() -> Array[Vector2]:
	var loc_list: Array[Vector2]
	for tile: TILE in TILES:
		loc_list.append(tile.LOCATION)
	return loc_list

func filter_closest_interactable_locations(start_loc: Vector2, loc_list: Array[Vector2]) -> Array[Vector2]:
	# takes in a list of target locations, determines if that location is interactable on-location, and if not, then find the closest interactable location to the start location
	var return_list: Array[Vector2] 
	for loc: Vector2 in loc_list:
		var passable: bool = is_passable(loc)
		if passable:
			return_list.append(loc)
		else:
			var new_loc: Vector2 = get_closest_adjacent_location(start_loc, loc)
			if new_loc == Vector2.INF:
				continue
			return_list.append(new_loc)
	
	return return_list

func filter_closest_interactable_locations_dict(start_loc:Vector2, loc_list:Array[Vector2]) -> Dictionary:
	# returns {closest_loc: target_loc}
	var return_dict: Dictionary
	for loc: Vector2 in loc_list:
		var passable: bool = is_passable(loc)
		if passable:
			return_dict[loc] = loc
		else:
			var new_loc: Vector2 = get_closest_adjacent_location(start_loc, loc)
			if new_loc == Vector2.INF:
				continue
			return_dict[new_loc] = loc
	return return_dict


# func get_tiles_from_vector_list(vector_list: Array[Vector2]) -> Array[TILE]:
# 	if len(vector_list) == 0:
# 		return TILES
# 	var tile_list: Array[TILE]
# 	for v: Vector2 in vector_list:
# 		var tile: TILE = get_tile(v)
# 		tile_list.append(tile)
# 	return tile_list


# func filter_passable_locations_old(vector_list: Array[Vector2] = []) -> Array[Vector2]:
# 	var tile_list: Array[TILE] = get_tiles_from_vector_list(vector_list)
# 	var passable_locations: Array[Vector2]
# 	for tile: TILE in tile_list:
# 		var tile_data: Dictionary = Constants.TILE_TEMPLATES[tile.TYPE]
# 		if tile_data["impassable"] == false:
# 			passable_locations.append(tile.LOCATION)
# 	return passable_locations


# func is_impassable_old(location: Vector2) -> bool:
# 	var tile: TILE = get_tile(location)
# 	if tile == null:
# 		return true
# 	var tile_data: Dictionary = Constants.TILE_TEMPLATES[tile.TYPE]
# 	return tile_data["impassable"]




#endregion filters


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
		if !is_passable(n): continue
		valid_neighbors.append(n)
	var passable_locations: Array[Vector2] = filter_passable_locations(valid_neighbors)
	return passable_locations



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


	
func get_available_poses_for_tile(location: Vector2) -> Array:
	var tile: TILE = get_tile(location)
	var pose_class: String = Constants.TILE_TEMPLATES[tile.TYPE]["poses"]
	return Constants.POSE_CLASS[pose_class]


func get_direction(from:Vector2, to:Vector2) -> String:
	if from.distance_to(to) >=2:
		push_error("spots too far apart!")
		return ""
		
	if from[1] < to[1]:
		return "down"
	elif from[1] > to[1]:
		return "up"
	elif from[0] < to[0]:
		return "right"
	else:
		return "left"

func get_location_from_mouse(loc: Vector2) -> Vector2:
	loc = Vector2(loc[0]-Constants.CENTER_PANEL_LOCATION[0], loc[1])
	var x:int = (int(loc[0]) / Constants.TILE_SIZE) + Global.X_RANGE[0]
	var y:int = (int(loc[1]) / Constants.TILE_SIZE) + Global.Y_RANGE[0]
	#var width: int = Constants.MAP_SIZE[0]
	#var index: int = (loc[1] * width) + loc[0]
	#var tile: TILE = TILES[index]
	return Vector2(x,y)

func highlight_tile(loc: Vector2, highlight_color: Color) -> void:
	#print("loc check", loc)
	var tile: TILE = get_tile(loc)
	tile.modulate = highlight_color

func get_furniture(id:String) -> Furniture:
	for furn: Furniture in FURNITURE:
		if furn.ID == id: return furn
	return null

func get_furniture_or_tile(id:String) -> Node:
	# tries to return furniture with id, if not return tile with id
	for furn: Furniture in FURNITURE:
		if furn.ID == id: return furn
	for tile: TILE in TILES:
		if tile.ID == id: return tile
	return null

#endregion utility
