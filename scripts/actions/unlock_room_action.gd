class_name UnlockRoomAction extends ACTION

var MOVING_FOR:ACTION
var PATH: Array[Vector2]
var TARGET_ROOM:ROOM

var ROOM_UNLOCKED:bool = false

func _init(engine, owner:NPC) -> void:
	ID = "move"
	ENGINE = engine
	OWNER = owner


# func room_to_unlock(_room:ROOM) -> UnlockRoomAction:
# 	TARGET_ROOM = _room
# 	return self

func set_goal(moving_for:ACTION) -> UnlockRoomAction:
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	return self


# func calling_action(moving_for:ACTION) -> UnlockRoomAction:
# 	MOVING_FOR = moving_for
# 	CHATTABLE = moving_for.CHATTABLE
# 	return self



# func tick() -> ActionResult:
# 	var result:ActionResult = run()
# 	return result

func enter_state() -> void:
	TARGET_ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if !TARGET_ROOM.is_secured():
		ROOM_UNLOCKED = true


func run() -> ActionResult:
	if ROOM_UNLOCKED:
		return ActionResult.new("end")
	else:
		for door:DOOR in TARGET_ROOM.DOOR_LIST:
			if !door.opened:
				var new_action:ACTION = OpenDoorAction.new(ENGINE, OWNER).set_target(door)
				return ActionResult.new("add", new_action)
		return ActionResult.new("running")
	# for door:DOOR in TARGET_ROOM.DOOR_LIST:
	# 	if !door.opened:
	# 		if OWNER.LOCATION == door.LOCATION:
	# 			door.open()
	# 		else:
	# 			#var new_action:MoveAction = MoveAction.new(ENGINE, OWNER, door, self).set_location(door.LOCATION)
	# 			var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(door).calling_action(MOVING_FOR)
	# 			return ActionResult.new("add", move_action).continuing()
	# return ActionResult.new("end").continuing()

func _to_string() -> String:
	var str_list:Array[String] = [
		# "[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is unlocking room for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)
