class_name MoveAction extends ACTION

var MOVING_FOR:ACTION

func _init(engine, owner: NPC, target: TILE, moving_for:ACTION) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "move"
	LOCATION = target.LOCATION
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


func run() -> ActionResult:
	if OWNER.LOCATION == LOCATION:
		return ActionResult.new("end", null)
		#return ["end", null]
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


		#var new_direction:String = ENGINE.Map.get_direction(old_location, next_step)
		#if new_direction != "":
	#		OWNER.update_direction(new_direction)

	
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
