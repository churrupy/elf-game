class_name MoveAction extends ACTION

var MOVING_FOR:ACTION
var PATH: Array[Vector2]

var secure:bool = false
var room_to_secure:ROOM

func _init(engine, owner:NPC) -> void:
	ID = "move"
	ENGINE = engine
	OWNER = owner



#func _init(engine, owner: NPC) -> void:
	## i hope this works lol
	## no scoring needed for this
	#ID = "move"
	#ENGINE = engine
	#OWNER = owner
	##TARGET = target
	##LOCATION = target.LOCATION
	##MOVING_FOR = moving_for
	##CHATTABLE = moving_for.CHATTABLE
	##super._init(engine, owner, target)
	#ENGINE.GroupManager.leave_group(owner)


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

	# if LOCATION == Vector2.INF:
	# 	# determine whether we have to be on location or next to location
	# 	var possible:bool = update_location()
	# 	if !possible:
	# 		return ActionResult.new("clear")
	# 	ENGINE.GroupManager.leave_group(OWNER)


	if OWNER.LOCATION == LOCATION:
		return ActionResult.new("continue")
		#return ["end", null]

	if TARGET != null:
		if TARGET is NPC:
			var target_action:ACTION = TARGET.STATE_STACK[-1]
			if !target_action.CHATTABLE:
				print("npc now unavailable")
				return ActionResult.new("continue")

		# check if target has moved
		if LOCATION.distance_to(TARGET.LOCATION) > 1.5:
			update_location()

	if len(PATH) == 0:
		# if path becomes invalid, they'll just teleport through things *sob*
		PATH = ENGINE.Map.get_pathfind_path(OWNER.LOCATION, LOCATION)
		if len(PATH) == 0:
			print("no valid path")
			return ActionResult.new("continue") #end move action and reassess goal

	# check that visible steps are still valid
	var filter:LOCATION_FILTER = LOCATION_FILTER.new(ENGINE).set_list(PATH).in_range_of(OWNER.LOCATION, 10).in_arc_of(OWNER.DIRECTION)
	var visible_loc:Array[Vector2] = filter.run_filter()
	filter = LOCATION_FILTER.new(ENGINE).set_list(visible_loc).is_passable()
	var passable_loc:Array[Vector2] = filter.run_filter()
	if len(visible_loc) != len(passable_loc):
		# if not all visible steps are passable
		print("path became invalid")
		return ActionResult.new("continue")
		
	

	var old_location:Vector2 = OWNER.LOCATION
	var next_step:Vector2 = PATH.pop_front()
	# var next_step:Vector2 = ENGINE.Map.step_towards_location(OWNER.LOCATION, LOCATION)
	OWNER.LOCATION = next_step
	
	var new_direction:Vector2 = next_step - old_location
	OWNER.update_direction(new_direction)
	ENGINE.History.add_move_event(OWNER)
	print("moving from ", old_location, " to ", next_step)

	if room_to_secure != null:
		# does not currently wait for other npcs
		var npc_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
		if npc_room == room_to_secure:
			if !room_to_secure.is_secured():
				#var new_action:LockRoomAction = LockRoomAction.new(ENGINE, OWNER, room_to_secure, MOVING_FOR)
				var new_action:LockRoomAction = LockRoomAction.new(ENGINE, OWNER).room_to_secure(room_to_secure).calling_action(MOVING_FOR)
				return ActionResult.new("add", new_action)
	

	return ActionResult.new("running")

func _to_string() -> String:
	var str_list:Array[String] = [
		"[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is moving for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)
