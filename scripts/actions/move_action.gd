class_name MoveAction extends ACTION

var MOVING_FOR:ACTION

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
	elif TARGET is Furniture:
		if "surface" in TARGET.DATA["type"]:
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

	print("###########location check")
	print(LOCATION)

	return true


func run() -> ActionResult:

	if LOCATION == Vector2.INF:
		# determine whether we have to be on location or next to location
		var possible:bool = update_location()
		if !possible:
			return ActionResult.new("clear")
		ENGINE.GroupManager.leave_group(OWNER)


	if OWNER.LOCATION == LOCATION:
		return ActionResult.new("end", null)
		#return ["end", null]

	if TARGET is NPC:
		var target_action:ACTION = TARGET.STATE_STACK[-1]
		if !target_action.CHATTABLE:
			print("npc now unavailable")
			return ActionResult.new("clear")

	# check if target has moved
	if LOCATION.distance_to(TARGET.LOCATION) > 1.5:
		update_location()
	
	var old_location: Vector2 = OWNER.LOCATION
	var next_step: Vector2 = ENGINE.Map.step_towards_location(OWNER.LOCATION, LOCATION)
	if next_step == Vector2.INF:
		push_error("pathfinding: no valid path found, teleporting ", OWNER, " to target location")
		print("teleporting...")
		OWNER.LOCATION = LOCATION
	else:
		OWNER.LOCATION = next_step

		var new_direction: Vector2 = next_step - old_location
		#print("new direction", new_direction)
		OWNER.update_direction(new_direction)
		ENGINE.History.add_move_event(OWNER)
	
	#ENGINE.History.add_event(OWNER.ID, "moves")
	return ActionResult.new("running", null)
	#return ["running", null]


# func _to_string():
# 	return "Moving for " + MOVING_FOR + str(LOCATION) + "(T:" + str(COUNTDOWN) + ")" + "Score: " + str(SCORE)


func _to_string():
	var str_list:Array[String] = [
		"[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is moving for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)
