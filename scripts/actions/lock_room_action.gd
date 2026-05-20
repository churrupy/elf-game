class_name LockRoomAction extends ACTION

var MOVING_FOR:ACTION
var PATH: Array[Vector2]
var TARGET_ROOM:ROOM

var ACTION_GROUP:GROUP
var PARTICIPANTS:Array[String]

var ROOM_CLEAR:bool = false
var ROOM_SECURED:bool = false

func _init(engine, owner:NPC) -> void:
	ID = "lock room"
	ENGINE = engine
	OWNER = owner

# func room_to_secure(_room:ROOM) -> LockRoomAction:
# 	TARGET_ROOM = _room
# 	return self

# func calling_action(moving_for:ACTION) -> LockRoomAction:
# 	MOVING_FOR = moving_for
# 	CHATTABLE = moving_for.CHATTABLE
# 	return self

func set_goal(moving_for:ACTION) -> LockRoomAction:
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	return self

# func set_group(_group:GROUP) -> LockRoomAction:
# 	ACTION_GROUP = _group
# 	PARTICIPANTS = ENGINE.GroupManager.get_group_participants_from_group(ACTION_GROUP)
# 	return self

# func tick() -> ActionResult:
# 	var result:ActionResult = run()
# 	return result


# func run_new() -> ActionResult:
# 	var action_result:ActionResult = ActionResult.new("running")
# 	var new_action:ACTION = ClearRoomAction.new(ENGINE, OWNER).set_target(TARGET) # target is a room, it's a work in progress
# 	# also waits until everyone is in the room as well
# 	action_result.ACTION_STACK.append(new_action)

# 	for d:DOOR in TARGET.DOOR_LIST:
# 		new_action = LockDoorAction.new(ENGINE, OWNER).set_target(d)
# 		action_result.ACTION_STACK.append(new_action)

# 	# maybe all complex actions like this aren't parents of sub-actions, but just replacing themselves with more granular actions on the action list
# 	# so all complex actions are replaced
# 	# (and if they don't want to be replaced, then add themselves onto the action stack)

# 	return action_result

	#how to stop this from running every single time?
	# stuck in a loop
	# should probably have some kind of "claim room" function that automatically kicks people out and stops them from re-entering if the room wants to be secured like this

func enter_state() -> void:
	# will lock current room
	TARGET_ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if TARGET_ROOM.is_secured():
		ROOM_SECURED = true
	else:
		var illegal_npcs:Array[NPC] = NPC_FILTER.new(ENGINE).set_list().set_room(TARGET_ROOM).is_not([OWNER]).run_filter()
		if len(illegal_npcs) == 0:
			ROOM_CLEAR = true


func run() -> ActionResult:
	if ROOM_SECURED:
		return ActionResult.new("end")

	if ROOM_CLEAR:
		for door:DOOR in TARGET_ROOM.DOOR_LIST:
			if door.opened:
				var new_action:ACTION = CloseDoorAction.new(ENGINE, OWNER).set_target(door)
				return ActionResult.new("add", new_action)
		return ActionResult.new("running")
	else:
		var illegal_npcs:Array[NPC] = NPC_FILTER.new(ENGINE).set_list().set_room(TARGET_ROOM).is_not([OWNER]).run_filter()
		for npc:NPC in illegal_npcs:
			var current_goal:ACTION = npc.GOAL_STACK.back()
			if current_goal is not ShooAction:
				var shoo_action:ACTION = ShooAction.new(ENGINE, npc).set_target(TARGET_ROOM)
				npc.GOAL_STACK.append(shoo_action)
		var wait_action:ACTION = WaitAction.new(ENGINE, OWNER)
		return ActionResult.new("action")
		

# func run_old() -> ActionResult:
# 	# shoo out other npcs
# 	if TARGET_ROOM == null:
# 		TARGET_ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
		
# 	var filter: NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().set_room(TARGET_ROOM)
# 	var npcs_in_room:Array[NPC] = filter.run_filter()
# 	# shoo out non-group npcs
# 	if len(npcs_in_room) > 0:
# 		var clearing_room:bool = false
# 		for npc:NPC in npcs_in_room:
# 			if ACTION_GROUP != null and npc.ID in PARTICIPANTS: continue
# 			clearing_room = true
# 			var current_action = npc.STATE_STACK.back()
# 			if current_action is not LeaveRoomAction or current_action is not ShooAction:
# 				var leave_action:ShooAction = ShooAction.new(ENGINE, npc).set_location()
# 				ENGINE.NpcManager.add_state(leave_action)
# 				# var leave_action:LeaveRoomAction = LeaveRoomAction.new(ENGINE, npc).set_location().calling_action(self)
# 				# ENGINE.NpcManager.add_state(leave_action)
# 		if clearing_room:
# 			print("uninvolved npcs still in room")
# 			return ActionResult.new("running")

# 	# wait for all group npcs to arrive
# 	# does not check to make sure that NPCs are still available
# 	if ACTION_GROUP != null:
# 		for id:String in PARTICIPANTS:
# 			var npc:NPC = Global.NPCS[id]
# 			if npc not in npcs_in_room:
# 				print("involved npcs not at room")
# 				print(npc)
# 				print(npcs_in_room)
# 				return ActionResult.new("running")
	
# 	# lock doors
# 	for door:DOOR in TARGET_ROOM.DOOR_LIST:
# 		if door.opened:
# 			if OWNER.LOCATION == door.LOCATION:
# 				door.close()
# 			else:
# 				var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(door).calling_action(self)
# 				return ActionResult.new("add", move_action)
# 	return ActionResult.new("end").continuing()


func _to_string() -> String:
	var str_list:Array[String] = [
		# "[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is locking room for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)
