class_name MoveToRoomAction extends ACTION

var ROOM_TAG:String

var TARGET_ROOM:ROOM
var TARGET_DOOR:DOOR

var PARTICIPANTS:Array[NPC]

var IN_ROOM:bool = false

# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner
# 	ID = "move to room"

# func set_tag(_tag:String) -> MoveToRoomGoal:
# 	ROOM_TAG = _tag
# 	return self

# func set_participants(npc_list:Array[NPC]) -> MoveToRoomGoal:
# 	PARTICIPANTS = npc_list.duplicate()
# 	return self

# func set_room(_room:ROOM) -> MoveToRoomGoal:
# 	TARGET_ROOM = _room
# 	return self

# func enter_state() -> void:
# 	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
# 	if current_room.has_tag(ROOM_TAG):
# 		print("current room has tag")
# 		IN_ROOM = true
# 		TARGET_ROOM = current_room
# 	elif TARGET_ROOM == null:
# 		print("current room does not have tag")
# 		var room_filter:ROOM_FILTER = ROOM_FILTER.new(ENGINE).set_list().has_tag(ROOM_TAG)
# 		var filtered_rooms:Array[ROOM] = room_filter.run_filter()
		
# 		if len(filtered_rooms) > 0:
# 			filtered_rooms.sort_custom(func(a,b): return a.LOCATION.distance_to(OWNER.LOCATION) < b.LOCATION.distance_to(OWNER.LOCATION))
# 			TARGET_ROOM = filtered_rooms.front()
# 			TARGET_DOOR = TARGET_ROOM.DOOR_LIST[0]

# 		else:
# 			TARGET_ROOM = null
# 			TARGET_DOOR = null
# 	else:
# 		TARGET_DOOR = TARGET_ROOM.DOOR_LIST[0]

func run() -> ActionResult:
	if "target_room" not in OWNER.BLACKBOARD or OWNER.BLACKBOARD["target_room"] == null:
		return ActionResult.new("fail")

	var target_room:ROOM = OWNER.BLACKBOARD["target_room"]
	if target_room.is_in_room(OWNER.LOCATION):
		return ActionResult.new("success")

	var target_tile:TILE = target_room.right_inside_door()
	# OWNER.BLACKBOARD["target_tile"] = target_tile

	ENGINE.NpcManager.remember_location(OWNER, target_tile.LOCATION)
	# var new_action:ACTION = MoveAction.new(ENGINE, OWNER)
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
	
# func run_old() -> ActionResult:
# 	var target_room:ROOM = OWNER.BLACKBOARD["target_room"]
# 	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
# 	if target_room == current_room:
# 		return ActionResult.new("end")

# 	var target_tile:TILE = target_room.right_inside_door()
# 	OWNER.BLACKBOARD["target_tile"] = target_tile
# 	var new_action:ACTION = MoveAction

# func run() -> ActionResult:
# 	print("IN_ROOM: ", IN_ROOM, ", TARGET_ROOM:", TARGET_ROOM)
# 	if IN_ROOM:
# 		return ActionResult.new("end")
# 	elif TARGET_ROOM == null:
# 		# no valid rooms found
# 		return ActionResult.new("end")
# 	else:
# 		# for p:NPC in PARTICIPANTS:
# 		# 	var new_action:ACTION = MoveAction.new
# 		var new_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_location(TARGET_DOOR.LOCATION).set_goal(self)
# 		return ActionResult.new("action", new_action)
