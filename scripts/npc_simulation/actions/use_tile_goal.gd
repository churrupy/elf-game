class_name UseTileGoal extends ACTION

var NEED:String

# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner


func set_need(_need:String) -> UseTileGoal:
	NEED = _need
	return self

func score() -> void:
	var need:float = OWNER.NEEDS[NEED]/100
	SCORE = 1 - (need * need) #not weighted per need

func run() -> ActionResult:
	if "target_need" not in OWNER.BLACKBOARD:
		return ActionResult.new("fail")
		
	var target_need:String = OWNER.BLACKBOARD["target_need"]
	print("using tile for ", target_need)
	if OWNER.NEEDS[target_need] >= 90:
		return ActionResult.new("success")
	# get all tiles that can fulfill need
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	var tile_list:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().set_room(current_room).set_fulfills_need(target_need).is_available().is_accessible_to(OWNER.LOCATION).run_filter()
	if len(tile_list) == 0:
		# check if there are any tiles on map, regardless of availability
		# if so, move to the closest and wait to become available
		# else, leave room
		tile_list = TILE_FILTER.new(ENGINE).set_list().set_room(current_room).set_fufills_need(target_need).run_filter()
		if len(tile_list) == 0:
			add_action(LeaveRoomAction)
			return ActionResult.new("continue")
		tile_list.sort_custom(func(a,b): return a.LOCATION.distance_to(OWNER.LOCATION) < b.LOCATION.distance_to(OWNER.LOCATION))
		OWNER.BLACKBOARD["target_location"] = tile_list[0].LOCATION
		add_action(WaitAction)
		add_action(MoveAction) #this ideally will keep looping every turn until the action is finally completable
		return ActionResult.new("continue")

	tile_list.sort_custom(func(a,b): return a.LOCATION.distance_to(OWNER.LOCATION) < b.LOCATION.distance_to(OWNER.LOCATION))
	var chosen_tile:TILE = tile_list[0]
	OWNER.BLACKBOARD["target_tile"] = chosen_tile
	OWNER.BLACKBOARD["target_room"] = ENGINE.Map.get_room(chosen_tile.LOCATION)
	OWNER.BLACKBOARD["goal"] = "refresh " + target_need

	var action_list:Array[GDScript] = [
		SatisfyNeedFromTileAction,
		MoveToTileAction,
		# MoveToRoomAction
	]

	if "private" in chosen_tile.DATA:
		ENGINE.GroupManager.leave_group(OWNER)
		if chosen_tile.DATA["private"]:
			action_list = [
				UnlockRoomAction,
				SatisfyNeedFromTileAction,
				MoveToTileAction,
				LockRoomAction,
				MoveToRoomAction,
			]

	for action_class:GDScript in action_list:
		# var new_action:ACTION = action_class.new(ENGINE,OWNER)
		add_action(action_class)

	return ActionResult.new("continue")

func run_old() -> ActionResult:
	print("using tile for ", NEED)
	if OWNER.NEEDS[NEED] >= 90:
		return ActionResult.new("success")
	# get all tiles that can fulfill need
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	var tile_list:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().set_room(current_room).set_fulfills_need(NEED).is_available().is_accessible_to(OWNER.LOCATION).run_filter()
	if len(tile_list) == 0:
		# check if there are any tiles on map, regardless of availability
		# if so, move to the closest and wait to become available
		# else, leave room
		return ActionResult.new("running")
	tile_list.sort_custom(func(a,b): a.LOCATION.distance_to(OWNER.LOCATION) < b.LOCATION.distance_to(OWNER.LOCATION))
	var chosen_tile:TILE = tile_list[0]
	OWNER.BLACKBOARD["target_tile"] = chosen_tile
	OWNER.BLACKBOARD["target_room"] = ENGINE.Map.get_room(chosen_tile.LOCATION)
	OWNER.BLACKBOARD["target_need"] = NEED
	OWNER.BLACKBOARD["goal"] = "refresh " + NEED

	var action_list:Array[GDScript] = [
		SatisfyNeedFromTileAction,
		MoveToTileAction,
		MoveToRoomAction
	]

	if "private" in chosen_tile.DATA:
		ENGINE.GroupManager.leave_group(OWNER)
		if chosen_tile.DATA["private"]:
			action_list = [
				UnlockRoomAction,
				SatisfyNeedFromTileAction,
				MoveToTileAction,
				LockRoomAction,
				MoveToRoomAction,
			]

	for action_class:GDScript in action_list:
		# var new_action:ACTION = action_class.new(ENGINE,OWNER)
		add_action(action_class)

	return ActionResult.new("continue")


func _to_string() -> String:
	var target_need:String = OWNER.BLACKBOARD["target_need"]
	var str_list:Array[String] = [
		OWNER.NAME,
		"is using tile for",
		target_need
	]
	return " ".join(str_list)
