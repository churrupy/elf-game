class_name MoveAction extends ACTION

var MOVING_FOR:ACTION
var PATH: Array[Vector2]

var secure:bool = false
var room_to_secure:ROOM


func _init(engine, owner:NPC) -> void:
	ID = "move"
	ENGINE = engine
	OWNER = owner
	SEEABLE = true


#region builder
func set_target(target:Node) -> MoveAction:
	TARGET = target
	update_location()
	return self

func calling_action(moving_for:ACTION) -> MoveAction:
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	return self

func set_location(loc:Vector2) -> MoveAction:
	# for if there's no set target
	LOCATION = loc
	return self

func secure_room() -> MoveAction:
	# builder function
	secure = true
	# room_to_secure = ENGINE.Map.get_room(LOCATION)
	return self


#endregion builder

func resume_state() -> void:
	update_path()


func tick() -> ActionResult:
	var result: ActionResult = run()
	OWNER.decay_needs()
	return result

# func tick_new():
# 	var result = run()
# 	return result

# func run_new():
# 	if OWNER.LOCATION == LOCATION:
# 		return "finish"
# 	var next_step: Vector2 = ENGINE.Map.step_towards_location(OWNER.LOCATION, LOCATION)
# 	if next_step == Vector2.INF:
# 		push_error("pathfinding: no valid path found, teleporting ", OWNER, " to target location")
# 		print("teleporting...")
# 		OWNER.LOCATION = LOCATION
# 	else:
# 		OWNER.LOCATION = next_step
	
# 	ENGINE.History.add_event(OWNER.ID, "moves")
# 	return "continue"

func update_location() -> void:
	var adjacent: bool = false
	if TARGET is NPC:
		adjacent = true
	elif TARGET is TILE:
		if "h_surface" in TARGET.DATA["tags"] or "v_surface" in TARGET.DATA["tags"]:
			adjacent = true
	
	if adjacent:
		var filter:LOCATION_FILTER = LOCATION_FILTER.new(ENGINE).generate_list(TARGET.LOCATION,1).is_passable().is_available().is_not(TARGET.LOCATION)
		var neighbors:Array[Vector2] = filter.run_filter()
		if len(neighbors) > 0:
			neighbors.sort_custom(func(a,b):OWNER.LOCATION.distance_to(b) > OWNER.LOCATION.distance_to(a))
			LOCATION = neighbors[0]
	else:
		LOCATION = TARGET.LOCATION

	update_path()

func update_path() -> void:
	# if path becomes invalid, they'll just teleport through things *sob*
	PATH = ENGINE.Map.get_pathfind_path(OWNER.LOCATION, LOCATION)


func run() -> ActionResult:

	# end moving
	if OWNER.LOCATION == LOCATION:
		return ActionResult.new("end").continuing()
		#return ["end", null]

	# target no longer valid
	if TARGET != null:
		if TARGET is NPC:
			var target_action:ACTION = TARGET.STATE_STACK[-1]
			if !target_action.CHATTABLE:
				print("npc now unavailable")
				return ActionResult.new("end").continuing()

		# check if target has moved
		if LOCATION.distance_to(TARGET.LOCATION) > 1.5:
			update_location()

	# path no longer valid
	if len(PATH) == 0:
		update_path()
		if len(PATH) == 0:
			return ActionResult.new("end").continuing()

	# check that current room is unlocked if necessary
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	var target_room:ROOM = ENGINE.Map.get_room(LOCATION)

	if current_room == target_room:
		if secure:
			if !current_room.is_secured():
				var new_action:LockRoomAction = LockRoomAction.new(ENGINE, OWNER).room_to_secure(target_room).calling_action(MOVING_FOR)
				return ActionResult.new("add", new_action).continuing()
	else:
		if current_room.is_secured():
			# print(current_room, "is locked?", current_room.is_secured())
			var new_action:UnlockRoomAction = UnlockRoomAction.new(ENGINE, OWNER).room_to_unlock(current_room).calling_action(MOVING_FOR)
			return ActionResult.new("add", new_action).continuing()
		

	# check that visible steps are still valid
	var filter:LOCATION_FILTER = LOCATION_FILTER.new(ENGINE).set_list(PATH).in_range_of(OWNER.LOCATION, 10).in_arc_of(OWNER.DIRECTION)
	var visible_loc:Array[Vector2] = filter.run_filter()
	filter = LOCATION_FILTER.new(ENGINE).set_list(visible_loc).is_passable()
	var passable_loc:Array[Vector2] = filter.run_filter()
	if len(visible_loc) != len(passable_loc):
		# if not all visible steps are passable
		print("path became invalid")
		return ActionResult.new("end").continuing()
		
	
	# move to next step
	var old_location:Vector2 = OWNER.LOCATION
	var next_step:Vector2 = PATH.pop_front()
	# var next_step:Vector2 = ENGINE.Map.step_towards_location(OWNER.LOCATION, LOCATION)
	OWNER.LOCATION = next_step
	
	var new_direction:Vector2 = next_step - old_location
	OWNER.update_direction(new_direction)
	# ENGINE.History.add_move_event(OWNER)
	ENGINE.History.create_event(self)
	print("moving from ", old_location, " to ", next_step)


	return ActionResult.new("running")

func _to_string() -> String:
	var str_list:Array[String] = [
		# "[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is moving for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)

func get_involved_npcs() -> Array[NPC]:
	return [OWNER]

func get_room() -> ROOM:
	var room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	return room


func is_equal(_event:EVENT_new) -> bool:
	var other_action:ACTION = _event.EVENT_ACTION
	if other_action is not MoveAction: return false
	if other_action.OWNER != OWNER: return false
	var current_room:ROOM = get_room()
	if _event.EVENT_ROOM != current_room: return false

	# if it's been long enough since event happened for action to be processed as a new action
	var tick_range:int = 100
	if _event.END_TICK + tick_range < Global.TICKS:
		return false

	return true

func get_role(npc:NPC) -> String:
	if npc == OWNER:
		return "participant"
	else:
		return "witness"
