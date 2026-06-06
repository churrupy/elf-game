class_name MoveToRoomAction extends ACTION

func set_id() -> void:
	ID = "MoveToRoomAction"

func run() -> ActionResult:
	if "target_room" not in OWNER.BLACKBOARD or OWNER.BLACKBOARD["target_room"] == null:
		return ActionResult.new("fail")

	var target_room:ROOM = OWNER.BLACKBOARD["target_room"]
	if target_room.is_in_room(OWNER.LOCATION):
		return ActionResult.new("success")

	var target_tile:TILE = target_room.right_inside_door()

	OWNER.BLACKBOARD["target_location"] = target_tile.LOCATION
	add_action(MoveAction)
	return ActionResult.new("running")
	

func _to_string() -> String:
	var target_room:ROOM = OWNER.BLACKBOARD["target_room"]
	var str_list:Array[String] = [
		OWNER.NAME,
		"is moving to",
		target_room.TYPE
	]
	
	return " ".join(str_list)
	
