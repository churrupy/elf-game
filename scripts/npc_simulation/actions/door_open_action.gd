class_name DoorOpenAction extends ACTION


func run() -> ActionResult:
	if "target_door" not in OWNER.BLACKBOARD or OWNER.BLACKBOARD["target_door"] == null:
		return ActionResult.new("fail")

	var target_door:DOOR = OWNER.BLACKBOARD["target_door"]
	if OWNER.LOCATION != target_door.LOCATION:
		OWNER.BLACKBOARD["target_location"] = target_door.LOCATION
		add_action(MoveAction)
		return ActionResult.new("continue")
	target_door.open()
	return ActionResult.new("success")

func _to_string() -> String:
	var target_door:DOOR = OWNER.BLACKBOARD["target_door"]
	var str_list:Array[String] = [
		OWNER.NAME,
		"is opening the door at",
		ENGINE.prettify_vector(target_door.LOCATION)
	]
	return " ".join(str_list)

