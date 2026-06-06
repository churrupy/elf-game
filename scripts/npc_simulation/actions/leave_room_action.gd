class_name LeaveRoomAction extends ACTION

var MOVING_FOR:ACTION
var TARGET_ROOM:ROOM

func set_id() -> void:
	ID = "LeaveRoomAction"

func _init(engine, owner:NPC, goal:ACTION = null) -> void:
	owner.BLACKBOARD["current_room"] = engine.Map.get_room(owner.LOCATION)
	super._init(engine, owner, goal)

func run() -> ActionResult:
	if "current_room" not in OWNER.BLACKBOARD:
		return ActionResult.new("fail")

	var saved_room:ROOM = OWNER.BLACKBOARD["current_room"]
	if !saved_room.is_in_room(OWNER.LOCATION):
		return ActionResult.new("success")

	var target_loc:Vector2 = saved_room.right_outside_door()
	if target_loc == Vector2.INF:
		# largest room on the map
		# will eventually be impossible

		STATUS = "fail"
		return ActionResult.new("end")

	OWNER.BLACKBOARD["target_location"] = target_loc
	print("leaving room: ", saved_room)
	add_action(MoveAction)
	return ActionResult.new("running")

func _to_string() -> String:
	var current_room:ROOM = OWNER.BLACKBOARD["current_room"]
	var str_list:Array[String] = [
		OWNER.NAME,
		"is leaving",
		str(current_room)
	]
	return " ".join(str_list)
