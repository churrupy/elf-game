class_name TILE_FILTER extends RefCounted

var ENGINE

var tile_list:Array[TILE]
var is_not_list:Array[TILE] = []
var filtered_list:Array[TILE]

var origin:Vector2 = Vector2.INF
var location:Vector2 = Vector2.INF
var distance:float = 1.5
var direction:Vector2 = Vector2.INF
var tags:Array[String] = []
var fulfills_need:String = ""

var target_room:ROOM
var not_room_list:Array[ROOM]
var accessible_from:Vector2 = Vector2.INF

var be_available:bool = false
var be_passable:bool = false
var can_be_empty:bool = true

var need_adjacent_tiles:int = 0

func _init(engine) -> void:
	ENGINE = engine

func set_list(_tile_list:Array[TILE] = []) -> TILE_FILTER:
	if _tile_list == []:
		tile_list = ENGINE.Map.TILES
	else:
		tile_list = _tile_list
	return self

func set_not(tile:TILE) -> TILE_FILTER:
	is_not_list.append(tile)
	return self

func set_list_from_vector(loc_list:Array[Vector2]) -> TILE_FILTER:
	for loc:Vector2 in loc_list:
		if loc == Vector2.INF: continue
		tile_list.append(ENGINE.Map.get_tile(loc))
	return self


func in_range_of(_origin:Vector2, _distance:float = 1.5) -> TILE_FILTER:
	origin=_origin
	distance=_distance
	return self

func in_arc_of(_direction:Vector2) -> TILE_FILTER:
	direction = _direction
	return self

func set_room(_room:ROOM) -> TILE_FILTER:
	target_room = _room
	return self

func set_not_room(_room:ROOM) -> TILE_FILTER:
	not_room_list.append(_room)
	return self

func has_tag(_tag:String) -> TILE_FILTER:
	tags.append(_tag)
	return self

func set_fulfills_need(_need:String) -> TILE_FILTER:
	fulfills_need = _need
	return self

func is_available() -> TILE_FILTER:
	be_available = true
	return self

func is_passable() -> TILE_FILTER:
	be_passable = true
	return self


func is_accessible_to(_loc:Vector2) -> TILE_FILTER:
	accessible_from = _loc
	return self


func set_location(loc:Vector2) -> TILE_FILTER:
	location = loc
	return self

func not_empty() -> TILE_FILTER:
	can_be_empty = false
	return self

func has_free_adjacent_tiles(num_tiles:int = 1) -> TILE_FILTER:
	need_adjacent_tiles = num_tiles
	return self

func run_filter() -> Array[TILE]:
	for tile:TILE in tile_list:
		if tile in is_not_list: continue

				

		if !can_be_empty:
			if tile.TYPE == "empty": continue

		if fulfills_need != "":
			if "refreshes" not in tile.DATA: continue
			if tile.DATA["refreshes"] != fulfills_need: continue

		if location != Vector2.INF:
			if tile.LOCATION != location:
				continue

		if origin != Vector2.INF:
			if origin.distance_to(tile.LOCATION) > distance:
				continue

			if direction != Vector2.INF:
				var _direction = origin.direction_to(tile.LOCATION)
				if _direction.dot(direction) <= -0.5:
					continue

		if len(tags) > 0:
			if !is_subset_of(tags, tile.DATA["tags"]): continue
			# var matched:bool = true
			# var t_tags:Array = tile.DATA["tags"]
			# for tag:String in tags:
			# 	if tag not in t_tags:
			# 		matched = false
			# 		break
			# if !matched: continue

		if be_available:
			if ENGINE.NpcManager.is_reserved(tile.LOCATION): continue
		
		if be_passable:
			if tile is DOOR:
				if origin != Vector2.INF: # is pathfinding rather than filtering
					if !tile.opened:
						# check if origin is in the same room as the door
						# if yes, then treat door as empty tile
						# if not, treat door as wall
						var door_room:ROOM = ENGINE.Map.get_room(tile.LOCATION)
						if !door_room.is_in_room(origin) : continue
				else: # is filtering, probably
					if !tile.opened: continue
			else:
				if tile.has_tag("h_surface") or tile.has_tag("v_surface"): continue

		if target_room != null:
			if !target_room.is_in_room(tile.LOCATION): continue

		# if target_room != null:
		# 	var tile_room:ROOM = ENGINE.Map.get_room(tile.LOCATION)
		# 	if tile_room != target_room: continue
		# 	if tile_room in not_room_list: continue

		if need_adjacent_tiles > 0:
			var filter:LOCATION_FILTER = LOCATION_FILTER.new(ENGINE).generate_list(origin, 1).is_available().is_passable().is_not(origin)
			var filtered_loc:Array[Vector2] = filter.run_filter()
			if len(filtered_loc) < need_adjacent_tiles:continue

		if accessible_from != Vector2.INF:
			var tile_room:ROOM = ENGINE.Map.get_room(tile.LOCATION)
			if !tile_room.is_in_room(accessible_from):
				# if origin is not in tile room
				if tile_room.is_secured(): continue

		filtered_list.append(tile)

	return filtered_list


func convert_to_loc() -> Array[Vector2]:
	var result_list:Array[Vector2]
	var loc_list:Array = filtered_list.map(func(a): return a.LOCATION)
	result_list.assign(loc_list)
	return result_list

func convert_to_actions(_npc:NPC) -> Array[ACTION]:
	# converts to UseItemAction
	var action_list:Array[ACTION]
	var checked_needs:Array[String]
	for t:TILE in filtered_list:
		if "refreshes" in t.DATA:
			if t.DATA["refreshes"] not in checked_needs:
				var refreshed_need:String = t.DATA["refreshes"]
				var new_goal:ACTION = UseTileGoal.new(ENGINE, _npc, null).set_need(refreshed_need)
				action_list.append(new_goal)
				checked_needs.append(refreshed_need)

	return action_list

# func convert_to_furn() -> Array[TILE]:
# 	var result_list:Array[TILE]
# 	var furn_list:Array = filtered_list.filter(func(a): return a.TYPE != "empty")
# 	result_list.assign(furn_list)
# 	return result_list


func is_subset_of(subset:Array, set:Array) -> bool:
	for i in subset:
		if i in set: continue
		else: return false

	return true
