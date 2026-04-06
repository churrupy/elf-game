class_name MoveAction extends ACTION

var MOVING_FOR: String

func _init(engine, owner: NPC, target: TILE, moving_for: String) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "move"
	LOCATION = target.LOCATION
	MOVING_FOR = moving_for
	super._init(engine, owner, target)

func tick() -> ActionResult:
	var result: ActionResult = run()
	OWNER.decay_needs()
	return result


func run() -> ActionResult:
	if OWNER.LOCATION == LOCATION:
		return ActionResult.new("end", null)
		#return ["end", null]
	var next_step: Vector2 = ENGINE.Map.step_towards_location(OWNER.LOCATION, LOCATION)
	if next_step == Vector2.INF:
		push_error("pathfinding: no valid path found, teleporting ", OWNER, " to target location")
		print("teleporting...")
		OWNER.LOCATION = LOCATION
	else:
		OWNER.LOCATION = next_step
	
	ENGINE.History.add_event(OWNER.ID, "moves")
	return ActionResult.new("running", null)
	#return ["running", null]


func _to_string():
	return "Moving for " + MOVING_FOR + str(LOCATION) + "(T:" + str(COUNTDOWN) + ")" + "Score: " + str(SCORE)
