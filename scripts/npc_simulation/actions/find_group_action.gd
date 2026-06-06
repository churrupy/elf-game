class_name FindGroupAction extends ACTION

func set_id() -> void:
	ID = "FindGroupAction"

func run() -> ActionResult:
	if CURRENT_ACTION != null:
		if CURRENT_ACTION.ID == "LeaveRoomAction" and CURRENT_ACTION.STATUS == "fail":
			print("in largest room, cannot leave")
			STATUS = "fail"
			return ActionResult.new("end")
	# if CURRENT_ACTION != null:
	# 	if CURRENT_ACTION.STATUS == "fail":
	# 		STATUS = "fail"
	# 		return ActionResult.new("end")
		
	var owner_group:GROUP = ENGINE.GroupManager.get_group(OWNER)
	if owner_group != null:
		print("already in group")
		print(owner_group.PARTICIPANTS)
		STATUS = "success"
		return ActionResult.new("end")

	if "target_npc" not in OWNER.BLACKBOARD:
		OWNER.BLACKBOARD["target_npc"] = null
	
	if OWNER.BLACKBOARD["target_npc"] != null:
		# check if they're still available
		if !OWNER.BLACKBOARD["target_npc"].is_available():
			OWNER.BLACKBOARD["target_npc"] = null

	if OWNER.BLACKBOARD["target_npc"] == null:
		var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
		var npc_list:Array[NPC] = NPC_FILTER.new(ENGINE).set_list().set_room(current_room).is_available().is_not([OWNER]).run_filter()
		print("available socializable npcs: ", npc_list)
		if len(npc_list) == 0:
			npc_list = NPC_FILTER.new(ENGINE).set_list().set_room(current_room).is_not([OWNER]).run_filter()
			for n:NPC in npc_list:
				print(n.NAME, " ", n.is_available(), " ", n.ACTION_STACK.back().ID)
			set_current_action(LeaveRoomAction)
			return ActionResult.new("continue")

		# eventually would like to also take into consideration the npc's group and what they're doing, when deciding what group to join
		var impression_list:Array[Impression] = OWNER.get_all_impressions(npc_list)
		impression_list.sort_custom(func(a,b): return a.SCORE > b.SCORE)

		OWNER.BLACKBOARD["target_npc"] = impression_list[0].TARGET

	var target_npc:NPC = OWNER.BLACKBOARD["target_npc"]

	if OWNER.LOCATION.distance_to(target_npc.LOCATION) > 1.5:
		add_action(MoveToNPCAction)
		return ActionResult.new("continue")

	print("joining npc, ", target_npc)
	var new_group:GROUP = ENGINE.GroupManager.join_npc(OWNER, target_npc)
	print("new group: ", new_group)
	STATUS = "success"
	return ActionResult.new("end")





# func run() -> ActionResult:
# 	var owner_group:GROUP = ENGINE.GroupManager.get_group(OWNER)
# 	if owner_group != null:
# 		return ActionResult.new("success")

# 	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
# 	var npc_list:Array[NPC] = NPC_FILTER.new(ENGINE).set_list().set_room(current_room).is_available().is_not([OWNER]).run_filter()
# 	if len(npc_list) == 0:
# 		# check if there are any NPCs on the map regardless of availability
# 		npc_list = NPC_FILTER.new(ENGINE).set_list().set_room(current_room).is_not([OWNER]).run_filter()
# 		if len(npc_list) == 0:
# 			add_action(LeaveRoomAction)
# 			return ActionResult.new("continue")

# 		# i don't like this very much, but I'll roll with it for now VVV
# 		for i in range(0,5):
# 			# wait for a little bit for someone to become available
# 			add_action(WaitAction)

# 		return ActionResult.new("running")
	
# 	# eventually would like to also take into consideration the npc's group and what they're doing, when deciding what group to join
# 	var impression_list:Array[Impression] = OWNER.get_all_impressions(npc_list)
# 	impression_list.sort_custom(func(a,b): return a.SCORE > b.SCORE)

# 	OWNER.BLACKBOARD["target_npc"] = impression_list[0].TARGET



# 	# var new_action:ACTION = JoinNpcAction.new(ENGINE, OWNER).set_goal(self)
# 	add_action(JoinNpcAction)
# 	return ActionResult.new("continue")



func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is looking for a group to join"
	]
	return " ".join(str_list)
