class_name IdleGoal extends ACTION


# func _init(engine, owner:NPC) -> void:
# 	ENGINE = engine
# 	OWNER = owner
# 	ID = "idle"
# 	CHATTABLE = true

func start_state() -> void:
	LOCATION = OWNER.LOCATION

func enter_state() -> void:
	print("entering idle state")

func resume_state() -> void:
	LOCATION = OWNER.LOCATION

func can_do_action() -> bool:
	return true

func run() -> ActionResult:
	var need_list:Array[ACTION] = [
		BladderGoal.new(ENGINE, OWNER, self).score(),
		HungerGoal.new(ENGINE, OWNER, self).score()
	]

	need_list.sort_custom(func(a,b): return a.SCORE > b.SCORE)
	var chosen_action:ACTION = need_list[0]
	if chosen_action.SCORE > 0.2:
		chosen_action.add_self_to_owner()
		return ActionResult.new("continue")

	add_action(SocializeAction)
	add_action(ConsumeAction)

	return ActionResult.new("continue")


# func run_old() -> ActionResult:
# 	print("calculating action...")
# 	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
# 	var room_loc:Array[Vector2] = current_room.get_locations()
# 	var action_list:Array[ACTION]
# 	# furniture actions
# 	var furn_filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().set_room(current_room).is_available()
# 	action_list += furn_filter.convert_to_actions(OWNER)
# 	# item actions
# 	var item_filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().set_room(current_room)
# 	item_filter.run_filter()
# 	action_list += item_filter.convert_to_actions(OWNER)
# 	# npc actions
# 	var npc_list:Array[NPC] = NPC_FILTER.new(ENGINE).set_list().set_room(current_room).is_available().is_not([OWNER]).run_filter()
# 	if len(npc_list) > 0:
# 		var socialize_action:ACTION = SocializeWithGoal.new(ENGINE, OWNER)
# 		action_list.append(socialize_action)



# 	print("possible actions", action_list)

# 	for a:ACTION in action_list:
# 		a.score()
	
# 	action_list.sort_custom(func(a,b): return a.SCORE > b.SCORE)

# 	var chosen_action:ACTION = action_list[0]
# 	if chosen_action.SCORE <= 0.2:
# 		# if none of the available actions are interesting enough, then leave the room
# 		# obviously if all of the needs are partially filled then this doesn't work, so i'll need some way to make the scores work out
		
# 		ENGINE.NpcManager.remember_current_room(OWNER)
# 		add_action(LeaveRoomAction)
# 		return ActionResult.new("continue")
# 	chosen_action.add_self_to_owner()
# 	# ENGINE.NpcManager.add_action(chosen_action)
# 	#add_action(chosen_action)
# 	return ActionResult.new("continue")

# func run_old() -> ActionResult:

# 	var goal_options:Array[ACTION] = [
# 		BladderGoal.new(ENGINE, OWNER).score(),
# 		HungerGoal.new(ENGINE, OWNER).score(),
# 		SocialGoal.new(ENGINE, OWNER).score(),
# 		FunGoal.new(ENGINE, OWNER).score()
# 	]


# 	goal_options.sort_custom(func(a,b): return a.SCORE > b.SCORE)
# 	print("goal check", goal_options)

# 	var new_action:ACTION = goal_options[0]
# 	return ActionResult.new("add", new_action)

	# var possible_actions:Array[ACTION] = [
	# 	BladderGoal.new(ENGINE,OWNER),
	# 	HungerGoal.new(ENGINE,OWNER),
	# 	SocialAction_new.new(ENGINE, OWNER)
	# ]

	# possible_actions.sort_custom(func(a,b):a.SCORE > b.SCORE)

	# #maybe have some kind of cool-down so they won't attempt to do an action repeatedly if it's not available as an option?

	# return ActionResult.new("add").set_action(possible_actions[0])


	# var result:ActionResult

	# if len(OWNER.ACTION_RESPONSES) > 0:
	# 	var new_action:ACTION = RespondAction.new(ENGINE, OWNER)
	# 	result = ActionResult.new("add", new_action)

	# if OWNER.NEEDS["bladder"] < 50:
	# 	var new_action:ACTION = BladderGoal.new(ENGINE, OWNER)
	# 	result = ActionResult.new("add", new_action)
		
	# elif OWNER.NEEDS["hunger"] < 50:
	# 	var new_action:ACTION = HungerGoal.new(ENGINE, OWNER)
	# 	result = ActionResult.new("add", new_action)
	
	# else:
	# 	var new_action:ACTION = SocialAction_new.new(ENGINE, OWNER)
	# 	result = ActionResult.new("add", new_action)

	# return result

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is idling"
	]
	return " ".join(str_list)
