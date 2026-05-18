class_name WaitAction extends ACTION

func _init(engine, owner) -> void:
	ENGINE = engine
	OWNER = owner
	COUNTDOWN = 1

func run() -> ActionResult:
	COUNTDOWN -= 1
	if COUNTDOWN < 0:
		return ActionResult.new("end")
	return ActionResult.new("running")