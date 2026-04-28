class_name ChangingMoveAction extends ACTION

# if target is something that moves

var MOVING_FOR:ACTION

func _init(engine, owner:NPC, target:NPC, moving_for:ACTION) -> void:
	ID = "move"
	#LOCATION = target.LOCATION
	MOVING_FOR = moving_for
	COUNTDOWN = 3
	CHATTABLE = MOVING_FOR.CHATTABLE
	super._init(engine, owner, target)

func tick() -> ActionResult:
	var result: ActionResult = run()
	OWNER.decay_needs()
	return result

func run() -> ActionResult:
	print("trying to move to ", TARGET.NAME)
	if OWNER.LOCATION.distance_to(TARGET.LOCATION) <= 1.5:
		print("at location")
		return ActionResult.new("end", null)

	# check if target is still available
	# var available_npcs:Array[NPC] = ENGINE.NpcManager.filter_available_npcs([TARGET])
	# if len(available_npcs) == 0:
	# 	print("npc now unavailable")
	# 	return ActionResult.new("clear")

	var target_action:ACTION = TARGET.STATE_STACK[-1]
	if !target_action.CHATTABLE:
		print("npc now unavailable")
		return ActionResult.new("clear")

	# update action location	
	if LOCATION == null or LOCATION.distance_to(TARGET.LOCATION) > 1.5:
		var new_location:Vector2 = ENGINE.Map.get_closest_adjacent_location(OWNER.LOCATION, TARGET.LOCATION)
		if new_location == Vector2.INF:
			print("no adjacent locations found")
			return ActionResult.new("elear", null) 

		LOCATION = new_location

	ENGINE.GroupManager.leave_group(OWNER)

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

func _to_string():
	var str_list:Array[String] = [
		"[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is moving for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)
