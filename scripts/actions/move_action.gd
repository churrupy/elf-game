class_name MoveAction extends ACTION

var MOVING_FOR:ACTION
var PATH: Array[Vector2]

var secure:bool = false
var room_to_secure:ROOM

func _init(engine, owner: NPC, target: Node, moving_for:ACTION) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "move"
	ENGINE = engine
	OWNER = owner
	TARGET = target
	#LOCATION = target.LOCATION
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	super._init(engine, owner, target)
	ENGINE.GroupManager.leave_group(owner)


#region builder
func set_location(loc:Vector2 = Vector2.INF) -> MoveAction:
	# builder function
	if loc == Vector2.INF:
		update_location()
	else:
		LOCATION = loc
	return self

func secure_room() -> MoveAction:
	# builder function
	room_to_secure = ENGINE.Map.get_room(LOCATION)
	return self


#endregion builder

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

func update_location() -> bool:
	var adjacent: bool = false
	if TARGET is NPC:
		adjacent = true
	elif TARGET is TILE:
		if "h_surface" in TARGET.DATA["tags"] or "v_surface" in TARGET.DATA["tags"]:
			adjacent = true
	
	if adjacent:
		# print("######### adjacent check")
		# print(OWNER.LOCATION)
		# print(TARGET.LOCATION)
		var filter:LOCATION_FILTER = LOCATION_FILTER.new(ENGINE).generate_list(TARGET.LOCATION,1).is_passable().is_available().is_not(TARGET.LOCATION)
		var neighbors:Array[Vector2] = filter.run_filter()
		if len(neighbors) == 0:
			return false
			# how to get it to communicate with BT that there's no available spots to do this right now??
		
		neighbors.sort_custom(func(a,b):OWNER.LOCATION.distance_to(b) > OWNER.LOCATION.distance_to(a))
		LOCATION = neighbors[0]
		print(LOCATION)
	else:
		LOCATION = TARGET.LOCATION

	PATH = []

	#print("###########location check")
	#print(LOCATION)

	return true


func run() -> ActionResult:

	if LOCATION == Vector2.INF:
		# determine whether we have to be on location or next to location
		var possible:bool = update_location()
		if !possible:
			return ActionResult.new("clear")
		ENGINE.GroupManager.leave_group(OWNER)


	if OWNER.LOCATION == LOCATION:
		return ActionResult.new("end")
		#return ["end", null]

	if TARGET is NPC:
		var target_action:ACTION = TARGET.STATE_STACK[-1]
		if !target_action.CHATTABLE:
			print("npc now unavailable")
			return ActionResult.new("clear")

	# check if target has moved
	if LOCATION.distance_to(TARGET.LOCATION) > 1.5:
		update_location()

	if len(PATH) == 0:
		PATH = ENGINE.Map.get_pathfind_path(OWNER.LOCATION, LOCATION)
		if len(PATH) == 0:
			print("no valid path")
			return ActionResult.new("clear")

	var old_location:Vector2 = OWNER.LOCATION
	var next_step:Vector2 = PATH.pop_front()
	OWNER.LOCATION = next_step
	
	var new_direction:Vector2 = next_step - old_location
	OWNER.update_direction(new_direction)
	ENGINE.History.add_move_event(OWNER)

	if room_to_secure != null:
		# does not currently wait for other npcs
		var npc_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
		if npc_room == room_to_secure:
			if !room_to_secure.is_secured():
				var new_action:LockRoomAction = LockRoomAction.new(ENGINE, OWNER, room_to_secure, MOVING_FOR)
				return ActionResult.new("add", new_action)
	
	# var old_location: Vector2 = OWNER.LOCATION
	# var next_step: Vector2 = ENGINE.Map.step_towards_location(OWNER.LOCATION, LOCATION)
	# if next_step == Vector2.INF:
	# 	push_error("pathfinding: no valid path found, teleporting ", OWNER, " to target location")
	# 	print("teleporting...")
	# 	OWNER.LOCATION = LOCATION
	# else:
	# 	OWNER.LOCATION = next_step

	# 	var new_direction: Vector2 = next_step - old_location
	# 	#print("new direction", new_direction)
	# 	OWNER.update_direction(new_direction)
	# 	ENGINE.History.add_move_event(OWNER)
	
	#ENGINE.History.add_event(OWNER.ID, "moves")
	return ActionResult.new("running", null)
	#return ["running", null]


# func _to_string():
# 	return "Moving for " + MOVING_FOR + str(LOCATION) + "(T:" + str(COUNTDOWN) + ")" + "Score: " + str(SCORE)


func _to_string() -> String:
	var str_list:Array[String] = [
		"[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is moving for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)
