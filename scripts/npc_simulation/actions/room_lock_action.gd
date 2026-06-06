class_name RoomLockAction extends ACTION



#func set_participants(npc_list:Array[NPC]) -> RoomLockAction:
	#PARTICIPANTS = npc_list.duplicate()
	#return self

func set_id() -> void:
	ID = "RoomLockAction"



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
			add_action(WaitAction, npc)
			var npc_room:ROOM = ENGINE.Map.get_room(npc.LOCATION)
			npc.BLACKBOARD["target_room"] = npc_room
			add_action(LeaveRoomAction, npc)
		
	if len(illegal_npcs) > 0:
		add_action(WaitAction)
		return ActionResult.new("running")

	# when I have groups set up again, then add group handling here maybe

	for door:DOOR in target_room.DOOR_LIST:
		if door.opened:
			OWNER.BLACKBOARD["target_door"] = door
			add_action(DoorCloseAction)
			return ActionResult.new("continue")
		
	return ActionResult.new("running")

		

func _to_string() -> String:
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	var str_list:Array[String] = [
		OWNER.NAME,
		"is locking",
		current_room.TYPE
	]
	return " ".join(str_list)
