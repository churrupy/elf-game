class_name MoveAction extends ACTION

var MOVING_FOR:ACTION
# var PATH: Array[Vector2]
var PATH:Pathfinder

var secure:bool = false
var room_to_secure:ROOM
var ACTION_GROUP:GROUP
var RANGE:float = 0


func _init(engine, owner:NPC) -> void:
	ID = "move"
	ENGINE = engine
	OWNER = owner
	SEEABLE = true


#region builder
# func set_target(target:Node) -> MoveAction:
# 	TARGET = target
# 	# print(TARGET)
# 	update_location()
# 	return self

func calling_action(moving_for:ACTION) -> MoveAction:
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	return self

func set_goal(moving_for:ACTION) -> MoveAction:
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	return self

func set_location(loc:Vector2) -> MoveAction:
	# for if there's no set target
	LOCATION = loc
	update_path()
	return self

# func secure_room() -> MoveAction:
# 	# builder function
# 	secure = true
# 	# room_to_secure = ENGINE.Map.get_room(LOCATION)
# 	return self

func set_group(_group:GROUP) -> MoveAction:
	ACTION_GROUP = _group
	return self

# func within_range(range:int = 1.5) -> MoveAction:
# 	# allows adjacent/nearby tiles as valid targets
# 	# good for moving as a group
# 	RANGE = range
# 	return self


#endregion builder

# func resume_state() -> void:
# 	update_path()


# func tick() -> ActionResult:
# 	var result: ActionResult = run()
# 	return result


# func update_location() -> void:
# 	if TARGET is NPC:
# 		RANGE = 1.5
# 	elif TARGET is TILE:
# 		if "h_surface" in TARGET.DATA["tags"] or "v_surface" in TARGET.DATA["tags"]:
# 			RANGE = 1.5

# 	var filter:LOCATION_FILTER = LOCATION_FILTER.new(ENGINE).generate_list(TARGET.LOCATION, RANGE).is_passable().is_available()
# 	#var filter:LOCATION_FILTER = LOCATION_FILTER.new(ENGINE).set_list().in_range_of(LOCATION, RANGE).is_available().is_passable()
# 	var filtered_loc:Array[Vector2] = filter.run_filter()
# 	if len(filtered_loc) == 0:
# 		# shouldn't happen! but we'll see
# 		print("adjacent move tiles not found")
# 	else:
# 		filtered_loc.sort_custom(func(a,b): return OWNER.LOCATION.distance_to(a) < OWNER.LOCATION.distance_to(b))
# 		LOCATION = filtered_loc[0]

# 	update_path()


func update_path() -> void:
	PATH = Pathfinder.new(ENGINE).set_start(OWNER.LOCATION).set_end(LOCATION)
	PATH.find_path()
	print("Pathfinder check: ", PATH)


func run() -> ActionResult:
	if LOCATION == Vector2.INF:
		print("invalid MoveAction target: ", LOCATION)
		return ActionResult.new("end")
	print("moving for", MOVING_FOR)
	if OWNER.LOCATION == LOCATION:
		print("reached location")
		return ActionResult.new("end")


	if !PATH.validate_from_npc(OWNER):
		print("path failed validation")
		return ActionResult.new("end")

	var old_location:Vector2 = OWNER.LOCATION
	var next_step:Vector2 = PATH.next_step()
	if next_step.distance_to(old_location) > 1.5:
		print("OWNER pushed too far away from path")
		return ActionResult.new("end")

	OWNER.LOCATION = next_step
	var new_direction:Vector2 = next_step - old_location
	OWNER.update_direction(new_direction)
	# ENGINE.History.add_move_event(OWNER)
	ENGINE.History.create_event(self)
	# print("moving from ", old_location, " to ", next_step)
	# print(PATH)

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
