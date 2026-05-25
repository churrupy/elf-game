class_name RespondGoal extends ACTION

var HAS_REQUESTS:bool = false

func _init(engine, owner) -> void:
	ENGINE = engine
	OWNER = owner
	ID = "respond"

func enter_state() -> void:
	if len(OWNER.ACTION_RESPONSES) > 0:
		HAS_REQUESTS = true
	else:
		HAS_REQUESTS = false


func run() -> ActionResult:
	# right now responds to all requests
	var res:ActionResult = ActionResult.new("end")
	if !HAS_REQUESTS:
		return res

	for goal:ACTION in OWNER.ACTION_RESPONSES:
		goal.score()
	
	OWNER.ACTION_RESPONSES.sort_custom(func(a,b): return a.SCORE > b.SCORE)

	var top_goal:ACTION = OWNER.ACTION_RESPONSES.pop_front()

	if top_goal.SCORE > 0:
		return ActionResult.new("replace", top_goal)
	
	return ActionResult.new("end")
	
