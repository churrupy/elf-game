class_name RoomUnlockAction extends ACTION

func set_id() -> void:
	ID = "RoomUnlockAction"


func run() -> ActionResult:
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if !current_room.is_secured():
		return ActionResult.new("success")

	for door:DOOR in current_room.DOOR_LIST:
		if !door.opened:
			OWNER.BLACKBOARD["target_door"] = door
			# var new_action:ACTION = OpenDoorAction.new(ENGINE, OWNER).set_target(door)
			add_action(DoorOpenAction)

	return ActionResult.new("running")


func _to_string() -> String:
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	var str_list:Array[String] = [
		OWNER.NAME,
		"is unlocking",
		current_room.TYPE
	]
	return " ".join(str_list)
