class_name MoveToTileAction extends ACTION

var ON_TILE:bool = false
var IN_TILE_ROOM:bool = false
var ROOM_SECURED:bool = false

var TILE_TAG:String
var secure_room:bool = false


# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner
# 	ID = "move to tile"


# func set_tag(_tag:String) -> MoveToTileGoal:
# 	TILE_TAG = _tag
# 	return self


# func to_secure() -> MoveToTileGoal:
# 	secure_room = true
# 	return self

# func enter_state() -> void:
# 	print("entering: MoveToTileAction")
# 	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
# 	if current_room.has_tag(TILE_TAG):
# 		IN_TILE_ROOM = true
# 		var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().set_room(current_room).has_tag(TILE_TAG)
# 		var tiles:Array[TILE] = filter.run_filter()
# 		for t:TILE in tiles:
# 			if OWNER.LOCATION == t.LOCATION:
# 				ON_TILE = true
# 				return
# 		TARGET = tiles[0]
# 		if TARGET.has_tag("adjacent_only"):
# 			var location_filter:LOCATION_FILTER = LOCATION_FILTER.new(ENGINE).generate_list(TARGET.LOCATION).is_available().is_passable().is_not(TARGET.LOCATION)
# 			var adjacent_loc:Array[Vector2] = location_filter.run_filter()
# 			adjacent_loc.sort_custom(func(a,b): return OWNER.LOCATION.distance_to(a) < OWNER.LOCATION.distance_to(b))
# 			LOCATION = adjacent_loc[0]
# 		else:
# 			LOCATION = tiles[0].LOCATION
# 		if secure_room:
# 			if current_room.is_secured():
# 				ROOM_SECURED = true
# 	else:
# 		IN_TILE_ROOM = false
# 		ON_TILE = false
# 		ROOM_SECURED = false

func run() -> ActionResult:
	if "target_tile" not in OWNER.BLACKBOARD:
		return ActionResult.new("fail")
	
	# adjust for interaction distance
	var target_tile:TILE = OWNER.BLACKBOARD["target_tile"]
	if target_tile.in_range(OWNER.LOCATION):
		return ActionResult.new("success")
	# if OWNER.LOCATION == target_tile.LOCATION:
	# 	return ActionResult.new("end")

	var target_location:Vector2 = ENGINE.Map.get_closest_interactable_location(OWNER, target_tile)

	# if target_tile.has_tag("only_adjacent"):
	# 	var tile_list:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().in_range_of(target_tile.LOCATION).is_not(target_tile).run_filter()
	# 	if len(tile_list) == 0:
	# 		return ActionResult.new("fail")
	# 	tile_list.sort_custom(func(a,b): a.LOCATION.distance_to(OWNER.LOCATION) < b.LOCATION.distance_to(OWNER.LOCATION))
	# 	target_tile = tile_list[0]
	# 	# OWNER.BLACKBOARD["target_tile"] = target_tile

	ENGINE.NpcManager.remember_location(OWNER, target_location)
	# var new_action:ACTION = MoveAction.new(ENGINE, OWNER)
	add_action(MoveAction)
	return ActionResult.new("continue")


func _to_string() -> String:
	var target_tile:TILE = OWNER.BLACKBOARD["target_tile"]
	var str_list:Array[String] = [
		OWNER.NAME,
		"is moving to",
		ENGINE.prettify_vector(target_tile.LOCATION)
	]
	return " ".join(str_list)

# func run() -> ActionResult:
# 	if "target_location" not in OWNER.BLACKBOARD or OWNER.BLACKBOARD["target_location"] == null:
# 		return ActionResult.new("end")

# 	if OWNER.BLACKBOARD["target_location"] == OWNER.LOCATION:
# 		return ActionResult.new("end")

# 	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
# 	var target_room:ROOM = ENGINE.Map.get_room(OWNER.BLACKBOARD["target_location"])

# 	if current_room == target_room:
# 		if OWNER.BLACKBOARD["secure_room"]:
# 			var new_goal:ACTION = LockRoomGoal.new(ENGINE, OWNER)
# 			return ActionResult.new("add", new_goal)
# 		else:
# 			var new_action:ACTION = MoveAction.new(ENGINE, OWNER)
# 			return ActionResult.new("action", new_action)

# 	else:
# 		var new_goal:ACTION = MoveToRoomGoal.new(ENGINE, OWNER)
# 		return ActionResult.new("add", new_goal)

# func run() -> ActionResult:
# 	if "location_tag" not in OWNER.BLACKBOARD or OWNER.BLACKBOARD["location_tag"] == null:
# 		return ActionResult.new("end")

	
	
# 	var current_room:ROOM = ENGINE.get_room(OWNER.LOCATION)
# 	var tagged_tiles:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().set_room(current_room).has_tag(OWNER.BLACKBOARD["location_tag"]).run_filter()
# 	if len(tagged_tiles) == 0:
# 		# move to tagged room
# 		pass
# 	else:
# 		# move to closest tile
# 		tagged_tiles.sort_custom(func(a,b): return a.LOCATION.distance_to(OWNER.LOCATION) < b.LOCATION.distance_to(OWNER.LOCATION))
# 		var chosen_tile:TILE = tagged_tiles[0]
# 		OWNER.BLACKBOARD["target_location"] = chosen_tile.LOCATION
# 		var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_location(chosen_tile.LOCATION)
# 		return ActionResult.new("action", new_action)

		
# func run_old() -> ActionResult:
# 	if ON_TILE:
# 		return ActionResult.new("end")
# 	elif IN_TILE_ROOM:
# 		if secure_room:
# 			if ROOM_SECURED:
# 				var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_location(LOCATION).set_goal(self)
# 				return ActionResult.new("action", new_action)
# 			else:
# 				var new_action:ACTION = LockRoomGoal.new(ENGINE, OWNER).set_goal(self)
# 				return ActionResult.new("add", new_action)
# 		else:
# 			var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_location(LOCATION).set_goal(self)
# 			return ActionResult.new("action", new_action)
# 	else:
# 		var new_action:ACTION = MoveToRoomGoal.new(ENGINE, OWNER).set_tag(TILE_TAG)
# 		return ActionResult.new("add", new_action)
