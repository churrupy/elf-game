class_name LockRoomAction extends ACTION

var MOVING_FOR:ACTION
var PATH: Array[Vector2]
var TARGET_ROOM:ROOM

var ACTION_GROUP:GROUP

func _init(engine, owner:NPC) -> void:
	ID = "move"
	ENGINE = engine
	OWNER = owner

func room_to_secure(_room:ROOM) -> LockRoomAction:
	TARGET_ROOM = _room
	return self

func calling_action(moving_for:ACTION) -> LockRoomAction:
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	return self

func set_group(_group:GROUP) -> LockRoomAction:
	ACTION_GROUP = _group
	return self

func tick() -> ActionResult:
	var result:ActionResult = run()
	return result


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

func run() -> ActionResult:
	# shoo out other npcs
	var filter: NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().is_in_room(TARGET_ROOM).is_not([OWNER])
	var npcs_in_room:Array[NPC] = filter.run_filter()
	# shoo out non-group npcs
	if len(npcs_in_room) > 0:
		for npc:NPC in npcs_in_room:
			if ACTION_GROUP != null and npc in ACTION_GROUP.PARTICIPANTS: continue
			var current_action = npc.STATE_STACK.back()
			if current_action is not LeaveRoomAction or current_action is not ShooAction:
				var leave_action:ShooAction = ShooAction.new(ENGINE, npc).set_location()
				ENGINE.NpcManager.add_state(leave_action)
				# var leave_action:LeaveRoomAction = LeaveRoomAction.new(ENGINE, npc).set_location().calling_action(self)
				# ENGINE.NpcManager.add_state(leave_action)
		return ActionResult.new("running")

	# wait for all group npcs to arrive
	# does not check to make sure that NPCs are still available
	if ACTION_GROUP != null:
		for npc:NPC in ACTION_GROUP.PARTICIPANTS:
			if npc not in npcs_in_room:
				return ActionResult.new("running")
	
	# lock doors
	for door:DOOR in TARGET_ROOM.DOOR_LIST:
		if door.opened:
			if OWNER.LOCATION == door.LOCATION:
				door.close()
			else:
				var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(door).calling_action(self)
				return ActionResult.new("add", move_action)
	return ActionResult.new("end").continuing()


func _to_string() -> String:
	var str_list:Array[String] = [
		# "[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is locking room for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)
