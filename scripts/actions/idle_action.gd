class_name IdleAction extends ACTION

# this class does determine_action
#var Determinator: ActionDeterminator

#func _init(engine, owner: NPC, target: Node, determinator: ActionDeterminator) -> void:
func _init(engine, owner:NPC) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "idle"
	LOCATION = owner.LOCATION
	#Determinator = determinator
	CHATTABLE = true
	super._init(engine, owner)

func start_state() -> void:
	LOCATION = OWNER.LOCATION

func enter_state() -> void:
	print("entering idle state")

func resume_state() -> void:
	LOCATION = OWNER.LOCATION

func can_do_action() -> bool:
	return true

func tick() -> ActionResult:
	#LOCATION = OWNER.LOCATION
	var result:ActionResult = run()
	return result

# func run() -> ActionResult:
# 	var action_list:Array[GDScript] = [
# 		BladderAction,
# 		HungerAction,
# 		# FunAction,
# 		# SocialAction,
# 	]

# 	for _action:GDScript in action_list:
# 		var res:ActionResult = _action.new(ENGINE, OWNER).run()
# 		if res.STATUS != "end":
# 			return res
# 	return ActionResult.new("running")

# func run() -> ActionResult:
# 	var new_action:ACTION

# 	if OWNER.NEEDS["hunger"] < 50:
# 		new_action = HungerAction.new(ENGINE, OWNER)
# 		ENGINE.NpcManager.add_state(new_action)

# 	if OWNER.NEEDS["bladder"] < 50:
# 		new_action = BladderAction.new(ENGINE,OWNER).find_target()
# 		ENGINE.NpcManager.add_state(new_action)

# 	return ActionResult.new("running")

func get_next_action() -> ACTION:
	return null # eventually just idling

func run() -> ActionResult:

	# var possible_actions:Array[ACTION] = [
	# 	BladderAction.new(ENGINE,OWNER),
	# 	HungerAction.new(ENGINE,OWNER),
	# 	SocialAction_new.new(ENGINE, OWNER)
	# ]

	# possible_actions.sort_custom(func(a,b):a.SCORE > b.SCORE)

	# #maybe have some kind of cool-down so they won't attempt to do an action repeatedly if it's not available as an option?

	# return ActionResult.new("add").set_action(possible_actions[0])


	var result:ActionResult

	if len(OWNER.RESPONSE_REQUESTS) > 0:
		var new_action:ACTION = RespondAction.new(ENGINE, OWNER)
		result = ActionResult.new("add", new_action)

	if OWNER.NEEDS["bladder"] < 50:
		var new_action:ACTION = BladderAction.new(ENGINE, OWNER)
		result = ActionResult.new("add", new_action)
		
	elif OWNER.NEEDS["hunger"] < 50:
		var new_action:ACTION = HungerAction.new(ENGINE, OWNER)
		result = ActionResult.new("add", new_action)
	
	else:
		var new_action:ACTION = SocialAction_new.new(ENGINE, OWNER)
		result = ActionResult.new("add", new_action)

	return result

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is idling"
	]
	return " ".join(str_list)

# func run_old() -> ActionResult:
# 	#print("running")
# 	Determinator.determine_next_action(OWNER)
# 	return ActionResult.new("running", null)


# func run_old() -> ActionResult:
# 	print("running")
# 	#var dialogue_string: String = OWNER.NAME + " is choosing a new action."
# 	#ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, [], dialogue_string)
# 	#LOCATION = OWNER.LOCATION # keeps in place for idling
# 	var all_actions: Array[ACTION] = ENGINE.Map.get_all_actions_on_map(OWNER)
# 	all_actions += ENGINE.NpcManager.get_all_npc_actions(OWNER)
# 	all_actions.sort_custom(func(a,b): return b.SCORE < a.SCORE)
# 	for action:ACTION in all_actions:
# 		if action.can_do_action():
# 			return ActionResult.new("add", action)
# 			#return ["add", action]

# 	print("no action found")
# 	return ActionResult.new("running", null)
# 	#return ["running", null]
