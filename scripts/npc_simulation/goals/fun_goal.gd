class_name FunGoal extends ACTION


# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner
# 	CHATTABLE = true

func score() -> FunGoal:
	var need:float = OWNER.NEEDS["fun"] / 100
	SCORE = 1 - (need * need)
	return self

func run() -> ActionResult:
	if OWNER.are_needs_low():
		return ActionResult.new("end")

	if OWNER.NEEDS["fun"] >= 80:
		return ActionResult.new("end")

	var new_action:ACTION = DanceAction.new(ENGINE, OWNER)
	return ActionResult.new("action", new_action)