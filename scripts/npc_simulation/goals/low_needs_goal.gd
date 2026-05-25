class_name LowNeedsGoal extends ACTION

func _init(engine, owner) -> void:
	ENGINE = engine
	OWNER = owner

func run() -> ActionResult:
	if OWNER.are_needs_low():
		# i think this goal is a good idea but i don't know how to build it in
		return ActionResult.new("end")
	
	else:
		return ActionResult.new("end")