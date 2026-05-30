class_name PeeAction extends ACTION

# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner
# 	ID = "pee"


func run() -> ActionResult:
	if OWNER.NEEDS["bladder"] >= 95:
		return ActionResult.new("end")
	else:
		refresh_needs("bladder")
		return ActionResult.new("running")