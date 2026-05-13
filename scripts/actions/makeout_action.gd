class_name MakeoutAction extends ACTION

var ENCOUNTER_GROUP: GROUP
#var COUNTDOWN: int = 5

func _init(engine, owner) -> void:
	ENGINE = engine
	OWNER = owner
	SEEABLE = true
	COUNTDOWN = 5
	ID = "make out"

func set_group(_group:GROUP) -> MakeoutAction:
	ENCOUNTER_GROUP = _group
	return self

func tick() -> ActionResult:
	return run()


func run() -> ActionResult:
	if COUNTDOWN <= 0:
		return ActionResult.new("end").continuing()
	COUNTDOWN -= 1
	ENGINE.History.create_event(self)
	return ActionResult.new("running")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is making out with",
		ENCOUNTER_GROUP.participants_to_string()
	]
	return " ".join(str_list)
