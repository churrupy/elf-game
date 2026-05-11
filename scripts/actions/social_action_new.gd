class_name SocialAction_new extends ACTION

var RECENT_TOPIC:String
# var RESPONSE_REQUESTS: Array[EVENT] = []
var RESPONSE_REQUESTS:Array[ACTION] = []

enum STATUS {
	RUNNING,
	FAILURE,
	SUCCESS
}


func _init(engine, owner: NPC, target: NPC=null) -> void:
	# no scoring needed for this
	ENGINE = engine
	OWNER = owner
	ID = "converse"
	#super._init(engine, owner, target)

# func can_do_action() -> bool:
# 	return ENGINE.NpcManager.is_available(TARGET)

# func score() -> void:
# 	# score based on need
# 	var need: int = OWNER.NEEDS["social"]
# 	SCORE += 100 - need

# 	# score based on preference
# 	if OWNER == TARGET:
# 		SCORE = -100
# 		return
# 	SCORE += get_opinion()
# 	if OWNER.NEEDS["release"] < 50 or OWNER.NEEDS["arousal"] > 30:
# 		SCORE += get_attraction()

# 	var closest_location: Vector2 = ENGINE.Map.get_closest_adjacent_location(OWNER.LOCATION, TARGET.LOCATION)
# 	if closest_location == Vector2.INF:
# 		SCORE = -100
# 		return
# 	LOCATION = closest_location

# func tick() -> ActionResult:
# 	var res:ActionResult = ActionResult.new("running", null)
# 	if !can_do_action():
# 		res.STATUS = "end"
# 		#res = ["end", null]
# 	elif OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
# 		res.STATUS = "add"
# 		res.NEW_ACTION = ChangingMoveAction.new(ENGINE, OWNER, TARGET, self)
# 	else:
# 		res = run()
# 	OWNER.decay_needs()
# 	return res

func tick() -> ActionResult:
	return run()

func run() -> ActionResult:
	var status: STATUS = determine_next_action()
	if status == STATUS.RUNNING:
		refresh_needs("social")
	return ActionResult.new("running")

# func run_old() -> ActionResult:
# 	var res: ActionResult = ActionResult.new("running")

# 	if !ENGINE.GroupManager.is_conversing(OWNER):
# 		var filter:NPC_FILTER = NPC_FILTER.new().set_list(ENGINE.NpcManager.NPCS).in_range_of(OWNER.LOCATION, 10).is_available().is_not([OWNER])
# 		var available_npcs:Array[NPC] = filter.run_filter()
# 		if len(available_npcs) == 0:
# 			print("no available npcs to talk to")
# 			return res
# 		var impressions:Array[Impression] = OWNER.get_all_impressions(available_npcs)
# 		impressions.sort_custom(func(a,b): b.SCORE < a.SCORE)

# 		var chosen_npc:NPC = impressions[0].TARGET
# 		var new_action:JoinGroupAction = JoinGroupAction.new(ENGINE, OWNER, chosen_npc)
# 		#ENGINE.GroupManager.join_npc(OWNER, chosen_npc)
# 		ENGINE.NpcManager.add_state(new_action)
# 		return res
	

# 	# process responses
# 	for event:EVENT in RESPONSE_REQUESTS:
# 		var response: String = event.process_response()
# 		if response == "introduce":
# 			# creates stupid infinite loop right now booooooo
# 			# need to separate introducing self and prompting the other person into two different categories
# 			print("introduction response: ", OWNER, event.SPEAKER)
# 			var added:bool = ENGINE.History.add_statement_event(OWNER, event.SPEAKER)
# 			if added:
# 				RESPONSE_REQUESTS = []
# 				return res
# 	RESPONSE_REQUESTS = []

# 	# introduce self
# 	for npc:NPC in group_participants:
# 		if npc == OWNER: continue
# 		if !OWNER.knows_npc(npc): 
# 			# introduce self
# 			print("introducing")
# 			var added1:bool = ENGINE.History.add_statement_event(OWNER, npc)	
# 			var added2:bool = ENGINE.History.add_prompt_event(OWNER, npc)
# 			if added1 and added2:
# 				return res

# 	var continue:bool = ENGINE.GroupManager.introduce_self(OWNER)
# 	if !continue:
# 		return res
# 	ENGINE.GroupManager.respond_to_topic(OWNER)

	# do talking stuff
	# var owner_group: GROUP = ENGINE.GroupManager.get_group(OWNER)
	# ENGINE.History.add_conversation_event(owner_group)
	# var group_participants: Array[NPC] = owner_group.PARTICIPANTS

	# update_direction
	# var average_vector: Vector2 = Vector2.ZERO
	# var npc_counter:int = 0
	# for npc:NPC in group_participants:
	# 	if npc == OWNER: continue
	# 	#var npc:NPC = Global.NPCS[npc_id]
	# 	var direction:Vector2 = npc.LOCATION - OWNER.LOCATION
	# 	average_vector += direction
	# 	npc_counter += 1
	
	# var average_direction: Vector2 = Vector2(average_vector[0]/npc_counter, average_vector[1]/npc_counter)
	# OWNER.update_direction(average_direction)

	

	# var new_topic: String = Dialogue.get_next_topic(owner_group.CURRENT_TOPIC)
	# var opinion: int = OWNER.OPINIONS[new_topic]
	# owner_group.CURRENT_TOPIC = new_topic
	# ENGINE.History.add_dialogue_event(OWNER, new_topic, opinion)
	#refresh_needs("social")
#
	#return res


# func run_old() -> ActionResult:
# 	# right now only people who're in conversation with them can hear them (no walkbys)
# 	print("running social action")
# 	var res: ActionResult = ActionResult.new("running")
# 	for event: EVENT in RESPONSE_REQUESTS:
# 		var response: String = event.process_response()
# 		if response == "introduce":
# 			print("introduction check")
# 			print(OWNER)
# 			print(event.SPEAKER)
# 			ENGINE.History.add_introduce_event(OWNER, event.SPEAKER, "")
# 		else:
# 			continue
# 		RESPONSE_REQUESTS = []
# 		#return res
			
# 	var witnesses: Array[String] = ENGINE.NpcManager.get_conversation_partners(OWNER)
# 	if len(witnesses) == 0:
# 		return res

# 	# figure out what direction npc should face
# 	var average_vector: Vector2 = Vector2.ZERO
# 	var npc_counter:int = 0
# 	for npc_id:String in witnesses:
# 		var npc:NPC = Global.NPCS[npc_id]
# 		var direction:Vector2 = npc.LOCATION - OWNER.LOCATION
# 		average_vector += direction
# 		npc_counter += 1
	
# 	var average_direction: Vector2 = Vector2(average_vector[0]/npc_counter, average_vector[1]/npc_counter)
# 	OWNER.update_direction(average_direction)

	
# 	# if don't know a witness, introduce self
# 	for npc_id:String in witnesses:
# 		var checked_npc: NPC = Global.NPCS[npc_id]
# 		if !OWNER.knows_npc(checked_npc): 
# 			# introduce self
# 			var tone: String = "" # will fix this eventualllyyyyy
# 			ENGINE.History.add_introduce_event(OWNER, checked_npc, tone)	
# 			#ENGINE.History.add_event(OWNER.ID, "introduce", npc_id)
# 			return res

# 	# if any witnesses npc has not interacted with in x ticks, greet them
# 	'''
# 	figure this out later
# 	'''
# 	# then talk about topics
# 	var new_topic: String = Dialogue.get_next_topic(RECENT_TOPIC)
# 	var opinion: int = OWNER.OPINIONS[new_topic]
# 	RECENT_TOPIC = new_topic
# 	var params: Dictionary = {
# 		"topic": new_topic,
# 		"opinion": opinion
# 	}
# 	#ENGINE.History.add_event(OWNER.ID, "converse", "", params)
# 	ENGINE.History.add_dialogue_event(OWNER, new_topic, opinion)
# 	refresh_needs("social")


# 	return res



# func flirt_old() -> Array:
# 	var impression = TARGET.hear_flirt(OWNER.ID)
# 	'''
# 	if !ENGINE.NpcManager.is_available(TARGET):
# 		impression = 0
# 	'''
# 	if impression == "pleased":
# 		# flirt accepted, try to find location
# 		# look for new location that has at least one adjacent open tile for encounter
# 		var locations: Array[Vector2] = ENGINE.Map.find_action_locations("encounter")
# 		locations = ENGINE.NpcManager.filter_reserved_locations(locations) # returns list

# 		for loc: Vector2 in locations:
# 			# target in this action is node
# 			var closest_loc: Vector2 = ENGINE.Map.get_closest_adjacent_location(TARGET.LOCATION, loc)
# 			if closest_loc == Vector2.INF: continue # no valid adjacent tiles

# 			var dialogue_string: String = OWNER.NAME + " tried to seduce " + TARGET.NAME
# 			#ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, [TARGET.ID], dialogue_string)

# 			dialogue_string = TARGET.NAME + " accepted the proposition!"
# 			#ENGINE.History.add_event(TARGET.ID, "converse", TARGET.LOCATION, [OWNER.ID], dialogue_string)

# 			# create new action for the both of them
# 			# right now seduction TARGET is the anchor and the OWNER is the node, but i'll figure out how I want to arrange that later

# 			var tile: TILE = ENGINE.Map.get_tile(loc)
# 			var new_action:ACTION = EncounterActionAnchor.new(ENGINE, TARGET, tile)
# 			ENGINE.NpcManager.add_state(new_action)

# 			new_action = EncounterActionNode.new(ENGINE, OWNER, TARGET)
# 			new_action.LOCATION = closest_loc

# 			return ["replace", new_action] # lol at having a class explicitly to start new states, and returning via a result like a schlub
		
# 		# seduce accepted but no valid locations turns it into a flirt

# 		var dialogue_string: String = OWNER.NAME + " flirted with " + TARGET.NAME
# 		ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, [TARGET.ID], dialogue_string)
# 		dialogue_string = TARGET.NAME + " was " + impression + " about being flirted with."
# 		ENGINE.History.add_event(TARGET.ID, "converse", TARGET.LOCATION, [OWNER.ID], dialogue_string)
		
# 	else:
# 		# seduce denied
# 		var dialogue_string: String = OWNER.NAME + " flirted with " + TARGET.NAME
# 		ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, [TARGET.ID], dialogue_string)
# 		dialogue_string = TARGET.NAME + " was annoyed about being flirted with."
# 		ENGINE.History.add_event(TARGET.ID, "converse", TARGET.LOCATION, [OWNER.ID], dialogue_string)
# 	return ["running", null]
	


func determine_next_action() -> STATUS:
	# sequence
	var node_list: Array[Callable] = [
		clear_responses,
		join_group,
		know_everyone,
		respond_to_topic
	]

	for node: Callable in node_list:
		#print("calling", node)
		var status: STATUS = node.call()
		if status != STATUS.SUCCESS: return status
	return STATUS.SUCCESS

func clear_responses() -> STATUS:
	for _action:ACTION in RESPONSE_REQUESTS:
		var new_action:ACTION = _action.process_response(OWNER)
		if new_action != null:
			ENGINE.NpcManager.add_state(new_action)
			RESPONSE_REQUESTS = [] # clear all responses/don't bank responses
			return STATUS.RUNNING
	return STATUS.SUCCESS

# func clear_responses() -> STATUS:
# 	for event:EVENT in RESPONSE_REQUESTS:
# 		var response: String = event.process_response()
# 		if response == "introduce":
# 			print("introduction response: ", OWNER, event.SPEAKER)
# 			# var added:bool = ENGINE.History.add_statement_event(OWNER, event.SPEAKER)
# 			#if added:
# 				#RESPONSE_REQUESTS = []
# 				#return STATUS.FAILURE
# 	RESPONSE_REQUESTS = []
# 	return STATUS.SUCCESS


func join_group() -> STATUS:
	if ENGINE.GroupManager.is_conversing(OWNER):
		return STATUS.SUCCESS
	else:
		var filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list(ENGINE.NpcManager.NPCS).in_range_of(OWNER.LOCATION, 10).is_available().is_not([OWNER])
		var available_npcs:Array[NPC] = filter.run_filter()
		if len(available_npcs) == 0:
			print("no available npcs to talk to")
			return STATUS.FAILURE
		var impressions:Array[Impression] = OWNER.get_all_impressions(available_npcs)
		impressions.sort_custom(func(a,b): b.SCORE < a.SCORE)
		for imp:Impression in impressions:
			var interactable_location:Vector2 = ENGINE.Map.get_closest_interactable_location(OWNER.LOCATION, imp.TARGET)
			if interactable_location != Vector2.INF:
				var chosen_npc:NPC = imp.TARGET
				var new_action:JoinGroupAction = JoinGroupAction.new(ENGINE, OWNER).set_target(chosen_npc)
				# var new_action:JoinGroupAction = JoinGroupAction.new(ENGINE, OWNER, chosen_npc)
				new_action.LOCATION = interactable_location
				#ENGINE.GroupManager.join_npc(OWNER, chosen_npc)
				ENGINE.NpcManager.add_state(new_action)
				return STATUS.RUNNING
	
	# might leave site at this point
	return STATUS.RUNNING

func know_everyone() -> STATUS:
	var group:GROUP = ENGINE.GroupManager.get_group(OWNER)
	for npc:NPC in group.PARTICIPANTS:
		if npc == OWNER: continue
		if !OWNER.knows_npc(npc):
			IntroduceAction.new(ENGINE, OWNER).set_target(npc).create_event()
			PromptIntroduceAction.new(ENGINE, OWNER).set_target(npc).create_event()
			# var new_action:ACTION = IntroduceAction.new(ENGINE, OWNER).set_target(npc).create_event()
			# ENGINE.NpcManager.add_state(new_action)
			# ENGINE.History.add_event(new_action)
			# new_action = PromptIntroduceAction.new(ENGINE, OWNER).set_target(npc).create_event()
			# ENGINE.History.add_event(new_action)
			return STATUS.RUNNING

	return STATUS.SUCCESS



#func know_everyone() -> STATUS:
	#var knows_everyone:bool = ENGINE.GroupManager.introduce_self(OWNER)
	#if knows_everyone:
		#return STATUS.SUCCESS
	#else:
		#return STATUS.FAILURE

func respond_to_topic() -> STATUS:
	ENGINE.GroupManager.respond_to_topic(OWNER)
	return STATUS.RUNNING
