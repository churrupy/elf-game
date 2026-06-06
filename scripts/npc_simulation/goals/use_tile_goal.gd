class_name UseTileGoal extends ACTION

var ACTION_LIST:Array[ACTION]

func set_it() -> void:
	ID = "UseTileGoal"

func start_action() -> void:
	if "target_tile" not in OWNER.BLACKBOARD:
		OWNER.BLACKBOARD["target_tile"] = null
	if "target_room" not in OWNER.BLACKBOARD:
		OWNER.BLACKBOARD["target_room"] = null

func end_action() -> void:
	OWNER.BLACKBOARD["target_tile"] = null
	OWNER.BLACKBOARD["target_room"] = null
	CURRENT_ACTION = null

func run() -> ActionResult:
	if "target_need" not in OWNER.BLACKBOARD:
		STATUS = "fail"
		return ActionResult.new("end")

	var target_need:String = OWNER.BLACKBOARD["target_need"]
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)

	if OWNER.NEEDS[target_need] >= 90:
		if current_room.is_secured():
			set_current_action(RoomUnlockAction)
			return ActionResult.new("continue")
		STATUS = "success"
		return ActionResult.new("end")

	if OWNER.BLACKBOARD["target_tile"] != null:
		# check that current tile is still valid/accessible
		var tile_list:Array[TILE] = TILE_FILTER.new(ENGINE).set_list([OWNER.BLACKBOARD["target_tile"]]).is_available().is_accessible_to(OWNER.LOCATION).run_filter()
		if OWNER.BLACKBOARD["target_tile"] not in tile_list:
			OWNER.BLACKBOARD["target_tile"] = null

	if OWNER.BLACKBOARD["target_tile"] == null:
		var tile_list:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().set_room(current_room).set_fulfills_need(target_need).is_available().is_accessible_to(OWNER.LOCATION).run_filter()
		if len(tile_list) == 0:
			print("waiting for tile to become available")
			set_current_action(WaitAction)
			return ActionResult.new("continue")
			
		tile_list.sort_custom(func(a,b): return a.LOCATION.distance_to(OWNER.LOCATION) < b.LOCATION.distance_to(OWNER.LOCATION))
		var chosen_tile:TILE = tile_list[0]
		OWNER.BLACKBOARD["target_tile"] = chosen_tile

	var target_tile:TILE = OWNER.BLACKBOARD["target_tile"]
	var target_room:ROOM = ENGINE.Map.get_room(target_tile.LOCATION)
	OWNER.BLACKBOARD["target_room"] = target_room

	if target_room != current_room:
		set_current_action(MoveToRoomAction)
		return ActionResult.new("continue")

	if "private" in target_tile.DATA:
		if !current_room.is_secured():
			set_current_action(RoomLockAction)
			return ActionResult.new("continue")

	if OWNER.LOCATION != target_tile.LOCATION:
		set_current_action(MoveToTileAction)
		return ActionResult.new("continue")
	
	set_current_action(SatisfyNeedFromTileAction)
	return ActionResult.new("running")

# func run_old() -> ActionResult:
# 	if "target_need" not in OWNER.BLACKBOARD:
# 		return ActionResult.new("fail")
		
# 	var target_need:String = OWNER.BLACKBOARD["target_need"]
# 	print("using tile for ", target_need)
# 	if OWNER.NEEDS[target_need] >= 90:
# 		return ActionResult.new("success")
# 	# get all tiles that can fulfill need
# 	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
# 	var tile_list:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().set_room(current_room).set_fulfills_need(target_need).is_available().is_accessible_to(OWNER.LOCATION).run_filter()
# 	if len(tile_list) == 0:
# 		print("waiting for tile to become available")
# 		# check if there are any tiles on map, regardless of availability
# 		# if so, move to the closest and wait to become available
# 		# else, leave room
# 		tile_list = TILE_FILTER.new(ENGINE).set_list().set_room(current_room).set_fulfills_need(target_need).run_filter()
# 		if len(tile_list) == 0:
# 			add_action(LeaveRoomAction)
# 			return ActionResult.new("continue")
# 		tile_list.sort_custom(func(a,b): return a.LOCATION.distance_to(OWNER.LOCATION) < b.LOCATION.distance_to(OWNER.LOCATION))
# 		OWNER.BLACKBOARD["target_location"] = tile_list[0].LOCATION
# 		add_action(WaitAction)
# 		add_action(MoveAction) #this ideally will keep looping every turn until the action is finally completable
# 		return ActionResult.new("continue")

# 	tile_list.sort_custom(func(a,b): return a.LOCATION.distance_to(OWNER.LOCATION) < b.LOCATION.distance_to(OWNER.LOCATION))
# 	var chosen_tile:TILE = tile_list[0]
# 	OWNER.BLACKBOARD["target_tile"] = chosen_tile
# 	OWNER.BLACKBOARD["target_room"] = ENGINE.Map.get_room(chosen_tile.LOCATION)
# 	OWNER.BLACKBOARD["goal"] = "refresh " + target_need

# 	# if any of these fail, there's no way to clear the whole path and return to here

# 	var action_list:Array[GDScript] = [
# 		SatisfyNeedFromTileAction,
# 		MoveToTileAction,
# 		# MoveToRoomAction
# 	]

# 	if "private" in chosen_tile.DATA:
# 		ENGINE.GroupManager.leave_group(OWNER)
# 		if chosen_tile.DATA["private"]:
# 			action_list = [
# 				RoomUnlockAction,
# 				SatisfyNeedFromTileAction,
# 				MoveToTileAction,
# 				RoomLockAction,
# 				MoveToRoomAction,
# 			]

# 	for action_class:GDScript in action_list:
# 		# var new_action:ACTION = action_class.new(ENGINE,OWNER)
# 		add_action(action_class)

# 	return ActionResult.new("continue")


func _to_string() -> String:
	var target_need:String = OWNER.BLACKBOARD["target_need"]
	var str_list:Array[String] = [
		OWNER.NAME,
		"is looking for tile for",
		target_need
	]
	return " ".join(str_list)
