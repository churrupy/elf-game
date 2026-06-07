class_name MAP extends ColorRect

var ENGINE
var TILES: Array[TILE]
#var FURNITURE: Array[Furniture]
#var ROOM: String
var ROOM_LIST:Array[ROOM]
var MAP_SIZE:Vector2

@export var tile_scene: PackedScene
	
#region init

func _init(engine, room) -> void:
	ENGINE = engine
	#ROOM = room
	#size = Global.MAIN_FRAME_SIZE
	#position = Constants.MAIN_FRAME_POSITION
	color = Color(.3, .3, .3)
	# size = Constants.CENTER_PANEL_SIZE
	# global_position = Constants.CENTER_PANEL_LOCATION
	_process(0.0)

	var room_data: Dictionary = Rooms.ROOM_TEMPLATES[room]
	var room_size: Vector2 = room_data["size"]
	MAP_SIZE = room_size
	var room_area: int = room_size[0] * room_size[1]

	var width:int = room_size[0]

	for i in range(0,room_area):
		var x:int = i%width
		var y:int = i/width
		var location: Vector2 = Vector2(x,y)
		var tile:TILE = TILE.new(location)
		TILES.append(tile)
		ENGINE.InventoryManager.create_inventory(tile)
		# print(tile)

	# print_map()

	create_room(room)

	# print_map()

func get_walls(_size:Vector2) -> Array[Vector2]:
	# walls are included in room size
	var wall_list:Array[Vector2]

	for i in range(0,_size[0]):
		wall_list.append(Vector2(i,0))
		wall_list.append(Vector2(i,_size[1]-1))
	for j in range(0,_size[1]):
		wall_list.append(Vector2(0,j))
		wall_list.append(Vector2(_size[0]-1,j))

	return wall_list

func is_inside_map(loc:Vector2) -> bool:
	if loc[0] < 0 or loc[0] >= MAP_SIZE[0]:
		return false
	if loc[1] < 0 or loc[1] >= MAP_SIZE[1]:
		return false
	return true

func create_room(type:String, top_left:Vector2 = Vector2.ZERO) -> ROOM:
	# tiles are all created at this point
	var room_data:Dictionary = Rooms.ROOM_TEMPLATES[type]
	var new_room:ROOM = ROOM.new(type, top_left, room_data["size"])

	if "walls" in room_data:
		print("creating walls for ", type)
		var _size:Vector2 = room_data["size"]
		var wall_list:Array[Vector2] = get_walls(_size)
		#print(wall_list)

		for relative_loc:Vector2 in wall_list:
			var loc = relative_loc + top_left
			if !is_inside_map(loc): continue # remove this to make map loop
			# print(loc)
			var tile:TILE = get_tile(loc)
			#print(tile)
			if relative_loc in room_data["doors"]:
				# print(loc)
				# make a door
				# doors never on a corner
				#tile.update_type("door")
				var wall:String
				if relative_loc[0] == 0:
					wall = "left"
				elif relative_loc[0] == _size[0]:
					wall = "right"
				elif relative_loc[1] == 0:
					wall = "up"
				elif relative_loc[1] == _size[1]:
					wall = "down"
				var new_door:DOOR = DOOR.new(loc, tile, wall)
				# set new door
				var width:int = MAP_SIZE[0]
				var index:int = (loc[1] * width) + loc[0]
				TILES[index] = new_door
 				#FURNITURE.append(new_door) #i'll figure out something related to this
				new_room.DOOR_LIST.append(new_door)
				ENGINE.InventoryManager.update_inventory_owner(new_door)
			
			else:
				tile.update_type("wall")

	for tile_type:String in room_data["furniture"].keys():
		var tile_data:Array = room_data["furniture"][tile_type]
		for rect:Array in tile_data:
			var start_vector:Vector2 = rect[0]
			var end_vector:Vector2 = rect[1]
			for i in range(int(start_vector[0]), int(end_vector[0])+1):
				for j in range(int(start_vector[1]), int(end_vector[1])+1):
					var loc:Vector2 = Vector2(i,j) + top_left
					var tile:TILE = get_tile(loc)
					tile.update_type(tile_type)
					if "may_contain" in tile.DATA:
						for item_type:String in tile.DATA["may_contain"]:
							var amount:int = [0,1,2,3].pick_random()
							for k in range(0,amount+1):
								var new_item:ITEM = ITEM.new(item_type)
								ENGINE.InventoryManager.add_to_inventory(tile, new_item)
					if "contains" in tile.DATA:
						print("contains check")
						for item_type:String in tile.DATA["contains"]:
							var amount:int = [1,2,3].pick_random()
							for k in range(0,amount+1):
								var new_item:ITEM = ITEM.new(item_type)
								ENGINE.InventoryManager.add_to_inventory(tile, new_item)
						print(ENGINE.InventoryManager.get_inventory_of(tile.ID))

	for room_type:String in room_data["rooms"].keys():
		for relative_location:Vector2 in room_data["rooms"][room_type]:
			var loc:Vector2 = relative_location + top_left
			var new_subroom:ROOM = create_room(room_type, loc)
			new_room.SUBROOMS.append(new_subroom)
		
	ROOM_LIST.append(new_room)

	return new_room

	
#endregion init

#region update

func _process(_float) -> void:
	size = ENGINE.GameWindow.CENTER_PANEL_SIZE
	global_position = ENGINE.GameWindow.CENTER_PANEL_LOCATION

func clear_tiles():
	for child in get_children():
		if child is TILE:
			remove_child(child)

func update() -> void:
	print("map check")
	clear_tiles()
	var player_room:ROOM = get_room(ENGINE.get_node("Player").LOCATION)
	for tile: TILE in TILES:
		#[var x: int, var y: int] = tile.LOCATION

		var global_location:Vector2 = ENGINE.GameWindow.get_global_location(tile.LOCATION)
		# print(tile.LOCATION, " ", global_location)
		if global_location[0] < 0 or global_location[1] < 0:
			continue
		
		# adjust to make sure tile ends up in center panel
		global_location = global_location + Vector2(ENGINE.GameWindow.CENTER_PANEL_LOCATION[0], 0)
		# global_location[0] = global_location[0] + ENGINE.GameWindow.CENTER_PANEL_LOCATION[0]
		

		add_child(tile)
		tile.global_position = global_location

		# var screen_index: Vector2 = ENGINE.GameWindow.get_screen_index(tile.LOCATION)
		# if screen_index[0] < 0 or screen_index[1] < 0:
		# 	continue
		
		# add_child(tile)
		
		# tile.global_position[0] = (screen_index[0] * Constants.TILE_SIZE) + ENGINE.GameWindow.CENTER_PANEL_LOCATION[0]
		# tile.global_position[1] = screen_index[1] * Constants.TILE_SIZE
		
		# if is_in_line_of_sight(ENGINE.get_node("Player").LOCATION, tile.LOCATION):
		# 	#print(ENGINE.prettify_vector(tile.LOCATION), " is in line of sight")
		# 	tile.modulate = Color(1,1,0)
		# else: 
		# 	tile.modulate = Color(1,1,1)

		if player_room.is_in_room(tile.LOCATION):
			highlight_tile(tile.LOCATION, Color(1,1,0))
		else:
			highlight_tile(tile.LOCATION, Color(1,1,1))


#endregion update


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
	if int(target[0]) not in range(0, MAP_SIZE[0]) or int(target[1]) not in range(0, MAP_SIZE[1]):
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


#region filters
func is_passable(loc:Vector2, origin:Vector2) -> bool:

	var tile:TILE = get_tile(loc)
	if tile == null:
		return false
	elif tile is DOOR:
		if tile.opened: return true
		var tile_room:ROOM = get_room(tile.LOCATION)
		if tile_room.is_in_room(origin):
			return true
		else:
			return false
	else:
		var tags:Array = tile.DATA["tags"]
		if "h_surface" in tags or "v_surface" in tags:
			return false
		return true



func is_loc_visible(loc:Vector2) -> bool:
	var tile:TILE = get_tile(loc)
	var tags:Array = tile.DATA["tags"]
	if "door" in tags:
		return tile.opened
		# if tile.opened: return true
		# else: return false
	if "v_surface" in tags:
		return false
	return true

func get_all_locations() -> Array[Vector2]:
	var loc_list: Array[Vector2]
	for tile: TILE in TILES:
		loc_list.append(tile.LOCATION)
	return loc_list


# func filter_closest_interactable_locations(start_loc: Vector2, loc_list: Array[Vector2]) -> Array[Vector2]:
# 	# takes in a list of target locations, determines if that location is interactable on-location, and if not, then find the closest interactable location to the start location
# 	var res_list: Array[Vector2] 
# 	for loc: Vector2 in loc_list:
# 		var passable: bool = is_passable(loc)
# 		if passable:
# 			res_list.append(loc)
# 		else:
# 			var new_loc: Vector2 = get_closest_adjacent_location(start_loc, loc)
# 			if new_loc == Vector2.INF:
# 				continue
# 			res_list.append(new_loc)
	
# 	return res_list

# func filter_closest_interactable_locations_dict(start_loc:Vector2, loc_list:Array[Vector2]) -> Dictionary:
# 	# returns {closest_loc: target_loc}
# 	var return_dict: Dictionary
# 	for loc: Vector2 in loc_list:
# 		var passable: bool = is_passable(loc)
# 		if passable:
# 			return_dict[loc] = loc
# 		else:
# 			var new_loc: Vector2 = get_closest_adjacent_location(start_loc, loc)
# 			if new_loc == Vector2.INF:
# 				continue
# 			return_dict[new_loc] = loc
# 	return return_dict


#endregion filters



#region utility
func get_neighbors(loc:Vector2) -> Array[Vector2]:
	# var tile_filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().in_range_of(loc,1.5).is_available().is_passable()
	var tile_filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().in_range_of(loc,1.5).is_passable()
	tile_filter.run_filter()
	var loc_list:Array[Vector2] = tile_filter.convert_to_loc()
	return loc_list



# func get_closest_adjacent_location(start_location: Vector2, target_location: Vector2) -> Vector2:
# 	# gets tile adjacent to target that's closest to start location
# 	var neighbors: Array[Vector2] = get_neighbors(target_location)
# 	if start_location in neighbors:
# 		return start_location
	
# 	var free_neighbors: Array[Vector2] = ENGINE.NpcManager.filter_reserved_locations(neighbors)

# 	if len(free_neighbors) == 0:
# 		print("no free adjacent tiles found")
# 		return Vector2.INF
	
# 	var smallest_distance: float = 100
# 	var closest_tile: Vector2
# 	for v: Vector2 in free_neighbors:
# 		var distance: float = start_location.distance_to(v)
# 		if distance < smallest_distance:
# 			smallest_distance = distance
# 			closest_tile = v
# 	return closest_tile

#region closest interactable
	
func get_closest_interactable_location(start:Node, target:Node) -> Vector2:
	if target is NPC:
		return get_closest_interactable_location_npc(start, target)
	elif target is TILE:
		return get_closest_interactable_location_tile(start, target)
	else:
		return get_closest_interactable_location_tile(start, target)

func get_closest_interactable_location_npc(start:Node, target:NPC) -> Vector2:
	var target_range:Array = [0.1, 1.5]
	var npc_tile:TILE = get_tile(target.LOCATION)
	var tile_filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().in_range_of(target.LOCATION, target_range[1]).set_not(npc_tile)

	var tile_list:Array[TILE] = tile_filter.run_filter()
	tile_list.sort_custom(func(a,b): return a.LOCATION.distance_to(start.LOCATION) < b.LOCATION.distance_to(start.LOCATION))
	return tile_list[0].LOCATION

func get_closest_interactable_location_tile(start:Node, target:TILE) -> Vector2:
	var target_range:Array = target.DATA["interactable_range"]
	var tile_filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().in_range_of(target.LOCATION, target_range[1])
	if target_range[0] != 0.0:
		tile_filter.set_not(target)
	var tile_list:Array[TILE] = tile_filter.run_filter()
	tile_list.sort_custom(func(a,b): return a.LOCATION.distance_to(start.LOCATION) < b.LOCATION.distance_to(start.LOCATION))
	return tile_list[0].LOCATION

#endregion closest interactable

func get_tile(loc:Vector2) -> TILE:
	var width:int = MAP_SIZE[0]
	var index:int = (loc[1] * width) + loc[0]
	if index < 0 or index > len(TILES) -1:
		return null
	var tile:TILE = TILES[index]
	return tile

func get_tile_from_id(id:String) -> TILE:
	for tile:TILE in TILES:
		if tile.ID == id: return tile
	return null


func random_empty_tile() -> TILE:
	for tile:TILE in TILES:
		var tile_data: Dictionary = Constants.TILE_TEMPLATES[tile.TYPE]
		if tile_data["impassable"] == false: return tile
	return null


	
func get_available_poses_for_tile(location: Vector2) -> Array:
	var tile: TILE = get_tile(location)
	var pose_class: String = Constants.TILE_TEMPLATES[tile.TYPE]["poses"]
	return Constants.POSE_CLASS[pose_class]

func get_location_from_mouse(loc: Vector2) -> Vector2:
	loc = Vector2(loc[0] - ENGINE.GameWindow.CENTER_PANEL_LOCATION[0], loc[1])
	# loc = Vector2(loc[0]-Constants.CENTER_PANEL_LOCATION[0], loc[1])
	var x:int = (int(loc[0]) / ENGINE.GameWindow.TILE_SIZE) + ENGINE.GameWindow.X_RANGE[0]
	var y:int = (int(loc[1]) / ENGINE.GameWindow.TILE_SIZE) + ENGINE.GameWindow.Y_RANGE[0]
	#var width: int = Constants.MAP_SIZE[0]
	#var index: int = (loc[1] * width) + loc[0]
	#var tile: TILE = TILES[index]
	return Vector2(x,y)

func highlight_tile(loc: Vector2, highlight_color: Color) -> void:
	var tile: TILE = get_tile(loc)
	tile.modulate = highlight_color



func get_room(loc:Vector2) -> ROOM:
	for room:ROOM in ROOM_LIST:
		var result_room:ROOM = room.in_room(loc)
		if result_room != null:
			return result_room

	push_error("Room not found, IMPOSSIBLE", loc)
	print("Room not found: ", loc)
	return null


func print_map() -> void:
	for tile:TILE in TILES:
		print(tile)


#endregion utility
