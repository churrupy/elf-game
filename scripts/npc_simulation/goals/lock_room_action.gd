class_name LockRoomAction extends ACTION

var MOVING_FOR:ACTION
var PATH: Array[Vector2]
var TARGET_ROOM:ROOM

var ACTION_GROUP:GROUP
# var PARTICIPANTS:Array[String]
var PARTICIPANTS:Array[NPC]

var ROOM_CLEAR:bool = false
var EVERYONE_PRESENT:bool = false
var ROOM_SECURED:bool = false

# func _init(engine, owner:NPC) -> void:
# 	ID = "lock room"
# 	ENGINE = engine
# 	OWNER = owner


# func set_goal(moving_for:ACTION) -> LockRoomAction:
# 	MOVING_FOR = moving_for
# 	CHATTABLE = moving_for.CHATTABLE
# 	return self

func set_participants(npc_list:Array[NPC]) -> LockRoomAction:
	PARTICIPANTS = npc_list.duplicate()
	return self


# func enter_state() -> void:
# 	# will lock current room
# 	TARGET_ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
# 	if TARGET_ROOM.is_secured():
# 		ROOM_SECURED = true

# 	if OWNER not in PARTICIPANTS:
# 		PARTICIPANTS.append(OWNER)
		
# 	# for now just assume that no one will lock the door until everyone is present
# 	else:
# 		var illegal_npcs:Array[NPC] = NPC_FILTER.new(ENGINE).set_list().set_room(TARGET_ROOM).is_not(PARTICIPANTS).run_filter()
# 		if len(illegal_npcs) == 0:
# 			ROOM_CLEAR = true
# 		else:
# 			ROOM_CLEAR = false

# 		EVERYONE_PRESENT = true
# 		if len(PARTICIPANTS) > 1:
# 			for p:NPC in PARTICIPANTS:
# 				var npc_room:ROOM = ENGINE.Map.get_room(p.LOCATION)
# 				if npc_room != TARGET_ROOM:
# 					EVERYONE_PRESENT = false
# 					break
		
# 		if TARGET_ROOM.is_secured():
# 			ROOM_SECURED = true
# 		else:
			# ROOM_SECURED = false

func run() -> ActionResult:
	var target_room:ROOM = OWNER.BLACKBOARD["target_room"]
	if !target_room.is_in_room(OWNER.LOCATION):
		return ActionResult.new("fail")
	
	if target_room.is_secured():
		return ActionResult.new("success")

	var illegal_npcs:Array[NPC] = NPC_FILTER.new(ENGINE).set_list().set_room(target_room).is_not([OWNER]).run_filter()
	for npc:NPC in illegal_npcs:
		if !npc.has_action_id("leave room"):
			ENGINE.NpcManager.clear_actions(npc)
			# var new_action:ACTION = WaitAction.new(ENGINE, npc)
			add_action(WaitAction, npc)
			# var new_action:ACTION = WaitAction.new(ENGINE, npc, self)
			# new_action.add_self_to_owner()
			# add_action(WaitAction)

			ENGINE.NpcManager.remember_current_room(npc)
			add_action(LeaveRoomAction, npc)
			# new_action = LeaveRoomAction.new(ENGINE, npc, self)
			# new_action.add_self_to_owner()
			# add_action(LeaveRoomAction)
		# var current_action:ACTION = npc.ACTION_STACK.back()
		# if current_action is not ShooGoal:
		# 	var shoo_action:ACTION = ShooGoal.new(ENGINE, npc).set_target(target_room)
		# 	npc.ACTION_STACK.append(shoo_action)
		
	if len(illegal_npcs) > 0:
		# var new_action:ACTION = WaitAction.new(ENGINE, OWNER)
		add_action(WaitAction)
		return ActionResult.new("running")
		# return ActionResult.new("add", new_action)

	# when I have groups set up again, then add group handling here maybe

	for door:DOOR in target_room.DOOR_LIST:
		if door.opened:
			OWNER.BLACKBOARD["target_door"] = door
			# var new_action:ACTION = CloseDoorAction.new(ENGINE, OWNER).set_target(door)
			add_action(CloseDoorAction)
			return ActionResult.new("continue")
			# return ActionResult.new("add", new_action)
		
	return ActionResult.new("running")

# func run() -> ActionResult:

# 	if ROOM_SECURED and ROOM_CLEAR and EVERYONE_PRESENT:
# 		return ActionResult.new("end")

# 	if !ROOM_CLEAR:
# 		var illegal_npcs:Array[NPC] = NPC_FILTER.new(ENGINE).set_list().set_room(TARGET_ROOM).is_not([OWNER]).run_filter()
# 		for npc:NPC in illegal_npcs:
# 			var current_goal:ACTION = npc.GOAL_STACK.back()
# 			if current_goal is not ShooGoal:
# 				# target room is set here because npc location validation could push them out of the room and so we want to be specific about what room we're being pushed out of
# 				var shoo_action:ACTION = ShooGoal.new(ENGINE, npc).set_target(TARGET_ROOM)
# 				npc.GOAL_STACK.append(shoo_action)

# 	if !EVERYONE_PRESENT:
# 		for p:NPC in PARTICIPANTS:
# 			if p == OWNER:continue
# 			var p_room:ROOM = ENGINE.Map.get_room(p.LOCATION)
# 			if p_room != TARGET_ROOM:
# 				var tile_list:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().is_available().is_passable().set_room(TARGET_ROOM).run_filter()
# 				var chosen_tile:TILE = tile_list.pick_random()
# 				var move_action:ACTION = MoveAction.new(ENGINE, p).set_location(chosen_tile.LOCATION)
# 				p.CURRENT_ACTION = move_action

# 	print("ROOM CLEAR", ROOM_CLEAR)
# 	print("EVERYONE PRESENT", EVERYONE_PRESENT)

# 	if !ROOM_CLEAR or !EVERYONE_PRESENT:
# 		var wait_action:ACTION = WaitAction.new(ENGINE, OWNER)
# 		return ActionResult.new("action", wait_action)
# 	else:
# 		for door:DOOR in TARGET_ROOM.DOOR_LIST:
# 			if door.opened:
# 				var new_action:ACTION = CloseDoorGoal.new(ENGINE, OWNER).set_target(door)
# 				return ActionResult.new("add", new_action)
# 		return ActionResult.new("running") # shouldn't ever get here but who knows


		

func _to_string() -> String:
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	var str_list:Array[String] = [
		# "[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is locking",
		current_room.TYPE
	]
	return " ".join(str_list)
