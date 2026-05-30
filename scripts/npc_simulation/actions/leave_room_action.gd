class_name LeaveRoomAction extends ACTION

var MOVING_FOR:ACTION
var TARGET_ROOM:ROOM

func _init(engine, owner:NPC, goal:ACTION = null) -> void:
	owner.BLACKBOARD["current_room"] = engine.Map.get_room(owner.LOCATION)
	super._init(engine, owner, goal)

# func _init(engine, owner:NPC) -> void:
# 	ID = "leave room"
# 	ENGINE = engine
# 	OWNER = owner

# func set_target() -> LeaveRoomAction:
# 	OWNER.BLACKBOARD["target_room"] = ENGINE.Map.get_room(OWNER.LOCATION)
# 	return self

# func set_goal(moving_for:ACTION) -> LeaveRoomAction:
# 	MOVING_FOR = moving_for
# 	CHATTABLE = moving_for.CHATTABLE
# 	return self

# func set_location() -> LeaveRoomAction:
# 	# builder function
# 	var this_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
# 	if len(this_room.DOOR_LIST) == 0:
# 		print("NO DOOR ALERT!")
# 		print("this room is the biggest room on the map so npcs cannot leave it")
# 		print("CRASH!")
# 		return self
# 	var door:DOOR = this_room.DOOR_LIST.pick_random() # this will fuck up if the room exits to two different rooms
# 	var wall:String = door.wall

# 	var wall_dict:Dictionary = {
# 		"up": Vector2.UP,
# 		"down": Vector2.DOWN,
# 		"left": Vector2.LEFT,
# 		"right": Vector2.RIGHT
# 	}

# 	var target_direction:Vector2 = door.LOCATION + wall_dict[wall]
# 	LOCATION = target_direction
# 	return self



# func tick() -> ActionResult:
# 	var result:ActionResult = run()
# 	return result

func run() -> ActionResult:
	if "current_room" not in OWNER.BLACKBOARD:
		return ActionResult.new("fail")

	var saved_room:ROOM = OWNER.BLACKBOARD["current_room"]
	if !saved_room.is_in_room(OWNER.LOCATION):
		return ActionResult.new("success")

	var target_loc:Vector2 = saved_room.right_outside_door()
	if target_loc == Vector2.INF:
		return ActionResult.new("recalculate")
	ENGINE.NpcManager.remember_location(OWNER, target_loc)
	# var new_action:ACTION = MoveAction.new(ENGINE, OWNER)
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

# func run() -> ActionResult:
# 	if "current_room" not in OWNER.BLACKBOARD:
# 		return ActionResult.new("end")
	
# 	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
# 	if OWNER.BLACKBOARD["current_room"] != current_room:
# 		return ActionResult.new("end")
	
# 	if len(current_room.DOOR_LIST) == 0:
# 		print("NO DOOR ALERT!")
# 		print("this room is the biggest room on the map so npcs cannot leave it")
# 		OWNER.BLACKBOARD["in_largest_room"] = true
# 		return ActionResult.new("end")

# 	var outside_door:Vector2 = current_room.right_outside_door()
# 	var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_location(outside_door)
# 	return ActionResult.new("action", new_action)
