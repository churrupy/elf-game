class_name ChangingMoveAction extends ACTION

# if target is something that moves

var MOVING_FOR: String

func _init(engine, owner:NPC, target:NPC, moving_for:String) -> void:
	ID = "move"
	LOCATION = target.LOCATION
	MOVING_FOR = moving_for
	COUNTDOWN = 3
	super._init(engine, owner, target)

func tick() -> ActionResult:
	var result: ActionResult = run()
	OWNER.decay_needs()
	return result

func run() -> ActionResult:
	if OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
		LOCATION = ENGINE.Map.get_closest_adjacent_location(OWNER.LOCATION, TARGET.LOCATION)
	else:
		return ActionResult.new("end", null)
		#return ["end", null]

	var next_step: Vector2 = ENGINE.Map.step_towards_location(OWNER.LOCATION, LOCATION)
	if next_step == Vector2.INF:
		push_error("pathfinding: no valid path found, teleporting ", OWNER, " to target location")
		print("teleporting...")
		OWNER.LOCATION = LOCATION
	else:
		OWNER.LOCATION = next_step

	#ENGINE.History.add_event(OWNER.ID, "moves")
	return ActionResult.new("running", null)
	#return ["running", null]

func _to_string():
	return "Moving for " + MOVING_FOR + str(LOCATION) + "(T:" + str(COUNTDOWN) + ")" + "Score: " + str(SCORE)
