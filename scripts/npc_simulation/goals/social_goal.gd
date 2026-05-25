class_name SocialGoal extends ACTION

var RECENT_TOPIC:String
# var ACTION_RESPONSES: Array[EVENT] = []
var ACTION_RESPONSES:Array[ACTION] = []

var IS_IN_GROUP:bool = false
var KNOWS_EVERYONE:bool = false
var GROUP_PARTICIPANTS:Array[NPC]



func _init(engine, owner: NPC, target: NPC=null) -> void:
	# no scoring needed for this
	ENGINE = engine
	OWNER = owner
	ID = "converse"
	CHATTABLE = true

func score() -> SocialGoal:
	SCORE = 100 - OWNER.NEEDS["social"]
	print("social score: ", SCORE)
	return self



func enter_state() -> void:
	if ENGINE.GroupManager.is_conversing(OWNER):
		IS_IN_GROUP = true
		var id_list:Array[String] = ENGINE.GroupManager.get_group_participants(OWNER)
		GROUP_PARTICIPANTS = ENGINE.NpcManager.get_npcs_from_ids(id_list)

	else:
		IS_IN_GROUP = false
		GROUP_PARTICIPANTS = []
				

func run() -> ActionResult:
	if OWNER.are_needs_low():
		return ActionResult.new("end")

	LOCATION = OWNER.LOCATION
	if IS_IN_GROUP:
		var res:ActionResult
		# choose what to do next
		# var res:ActionResult = clear_responses()
		# if res != null:
		# 	return res
		
		res = know_everyone()
		if res != null:
			return res

		res = flirt()
		if res != null:
			return res

		res = respond_to_topic()
		if res != null:
			return res
	else:
		var new_action:ACTION = JoinGroupGoal.new(ENGINE, OWNER).set_goal(self)
		return ActionResult.new("add", new_action)
		# return join_group()
		

	return ActionResult.new("running")




# func know_everyone() -> ActionResult:
# 	# var group:GROUP = ENGINE.GroupManager.get_group(OWNER)
# 	for npc:NPC in GROUP_PARTICIPANTS:
# 		if npc == OWNER: continue
# 		if !OWNER.knows_npc(npc):
# 			IntroduceAction.new(ENGINE, OWNER).set_target(npc).create_event()
# 			PromptIntroduceAction.new(ENGINE, OWNER).set_target(npc).create_event()
# 			return ActionResult.new("running")
# 	return null

# func know_everyone() -> ActionResult:
# 	# print("$$$ know everyone check")
# 	for npc:NPC in GROUP_PARTICIPANTS:
# 		if npc == OWNER: continue
# 		if !OWNER.knows_npc(npc):
# 			print("doesn't know ", npc.NAME)
# 			var new_action:ACTION = TalkAction.new(ENGINE, OWNER)
# 			var statement:ACTION = IntroduceAction.new(ENGINE, OWNER).set_target(npc)
# 			new_action.add_statement(statement)
# 			statement = PromptIntroduceAction.new(ENGINE, OWNER).set_target(npc)
# 			new_action.add_statement(statement)
# 			return ActionResult.new("action", new_action)
# 	return null

func know_everyone() -> ActionResult:
	for npc:NPC in GROUP_PARTICIPANTS:
		if npc == OWNER: continue
		if !OWNER.knows_npc(npc):
			print("doesn't know ", npc.NAME)
			var new_goal:ACTION = IntroduceGoal.new(ENGINE, OWNER).set_target(npc)
			return ActionResult.new("add", new_goal)
	return null

func flirt() -> ActionResult:
	var impression_list:Array[Impression] = OWNER.get_all_impressions(GROUP_PARTICIPANTS)
	impression_list.sort_custom(func(a,b): return a.ATTRACTIVE > b.ATTRACTIVE)
	if len(impression_list) > 0:
		var chosen_npc:NPC = impression_list.front().TARGET
		var new_goal:SeduceGoal = SeduceGoal.new(ENGINE, OWNER).set_target(chosen_npc)
		return ActionResult.new("add", new_goal)
	return null

# func flirt() -> ActionResult:
# 	var impression_list:Array[Impression] = OWNER.get_all_impressions(GROUP_PARTICIPANTS)
# 	impression_list.sort_custom(func(a,b): return a.ATTRACTIVE > b.ATTRACTIVE)

# 	if len(impression_list) > 0:
# 		var statement:ACTION = SeduceAction.new(ENGINE, OWNER).set_target(impression_list[0].TARGET)
# 		var new_action:ACTION = TalkAction.new(ENGINE, OWNER).add_statement(statement)
# 		return ActionResult.new("action", new_action)
# 	return null

# func flirt() -> ActionResult:
# 	# check if action is already happening
# 	for _action:ACTION in OWNER.STATE_STACK:
# 		if (_action is SeduceAction or
# 			_action is EncounterAction):
# 				print("already getting busy")
# 				return ActionResult.new("running")
# 	var group:GROUP = ENGINE.GroupManager.get_group(OWNER)
# 	var impression_list:Array[Impression] = OWNER.get_all_impressions(group.PARTICIPANTS)
# 	impression_list.sort_custom(func(a,b): return a.ATTRACTIVE > b.ATTRACTIVE)
	
# 	if len(impression_list) > 0:
# 	# if impression_list[0].ATTRACTIVE > 0:
# 		SeduceAction.new(ENGINE, OWNER).set_target(impression_list[0].TARGET).create_event()
# 		return ActionResult.new("running")
# 	return null

func respond_to_topic() -> ActionResult:
	var new_action:ACTION = TalkAction.new(ENGINE, OWNER)
	return ActionResult.new("action", new_action)

# func respond_to_topic() -> ActionResult:
# 	OpineAction.new(ENGINE, OWNER).create_event()
# 	# ENGINE.GroupManager.respond_to_topic(OWNER)
# 	return ActionResult.new("running")
