class_name MakeoutAction extends ACTION

var ACTION_GROUP: GROUP
var PARTICIPANTS:Array[String]
#var COUNTDOWN: int = 5

func _init(engine, owner) -> void:
	ENGINE = engine
	OWNER = owner
	SEEABLE = true
	COUNTDOWN = 5
	ID = "make out"

func set_group(_group:GROUP) -> MakeoutAction:
	ACTION_GROUP = _group
	PARTICIPANTS = ENGINE.GroupManager.get_group_participants_from_group(ACTION_GROUP)
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
		" ".join(PARTICIPANTS),
		str(COUNTDOWN) + " left"
	]
	return " ".join(str_list)
