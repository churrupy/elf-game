class_name SocialAction_new extends ACTION

var RECENT_TOPIC:String


func _init(engine, owner: NPC, target: NPC=null) -> void:
	# no scoring needed for this
	ENGINE = engine
	OWNER = owner
	ID = "converse"
	#super._init(engine, owner, target)

func can_do_action() -> bool:
	return ENGINE.NpcManager.is_available(TARGET)

func score() -> void:
	# score based on need
	var need: int = OWNER.NEEDS["social"]
	SCORE += 100 - need

	# score based on preference
	if OWNER == TARGET:
		SCORE = -100
		return
	SCORE += get_opinion()
	if OWNER.NEEDS["release"] < 50 or OWNER.NEEDS["arousal"] > 30:
		SCORE += get_attraction()

	var closest_location: Vector2 = ENGINE.Map.get_closest_adjacent_location(OWNER.LOCATION, TARGET.LOCATION)
	if closest_location == Vector2.INF:
		SCORE = -100
		return
	LOCATION = closest_location

func tick() -> ActionResult:
	var res:ActionResult = ActionResult.new("running", null)
	if !can_do_action():
		res.STATUS = "end"
		#res = ["end", null]
	elif OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
		res.STATUS = "add"
		res.NEW_ACTION = ChangingMoveAction.new(ENGINE, OWNER, TARGET, ID)
	else:
		res = run()
	OWNER.decay_needs()
	return res


func run() -> ActionResult:
	print("running social action")
	var res: ActionResult = ActionResult.new("running")
	var witnesses: Array[String] = ENGINE.NpcManager.get_conversation_partners(OWNER)
	if len(witnesses) == 0:
		return res
	
	# if any witnesses are unknown to npc, introduce self
	for npc_id:String in witnesses:
		if npc_id == OWNER.ID: continue
		if npc_id not in OWNER.RELATIONSHIPS:
			# introduce self
			OWNER.RELATIONSHIPS[npc_id] = 0 			
			ENGINE.History.add_event(OWNER.ID, "introduce", npc_id)
			return res

	# if any witnesses npc has not interacted with in x ticks, greet them
	'''
	figure this out later
	'''
	# then talk about topics
	var new_topic: String = Dialogue.get_next_topic(RECENT_TOPIC)
	var opinion: int = OWNER.OPINIONS[new_topic]
	RECENT_TOPIC = new_topic
	var params: Dictionary = {
		"topic": new_topic,
		"opinion": opinion
	}
	ENGINE.History.add_event(OWNER.ID, "converse", "", params)
	refresh_needs("social")


	return res



func flirt_old() -> Array:
	var impression = TARGET.hear_flirt(OWNER.ID)
	'''
	if !ENGINE.NpcManager.is_available(TARGET):
		impression = 0
	'''
	if impression == "pleased":
		# flirt accepted, try to find location
		# look for new location that has at least one adjacent open tile for encounter
		var locations: Array[Vector2] = ENGINE.Map.find_action_locations("encounter")
		locations = ENGINE.NpcManager.filter_reserved_locations(locations) # returns list

		for loc: Vector2 in locations:
			# target in this action is node
			var closest_loc: Vector2 = ENGINE.Map.get_closest_adjacent_location(TARGET.LOCATION, loc)
			if closest_loc == Vector2.INF: continue # no valid adjacent tiles

			var dialogue_string: String = OWNER.NAME + " tried to seduce " + TARGET.NAME
			ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, [TARGET.ID], dialogue_string)

			dialogue_string = TARGET.NAME + " accepted the proposition!"
			ENGINE.History.add_event(TARGET.ID, "converse", TARGET.LOCATION, [OWNER.ID], dialogue_string)

			# create new action for the both of them
			# right now seduction TARGET is the anchor and the OWNER is the node, but i'll figure out how I want to arrange that later

			var tile: TILE = ENGINE.Map.get_tile(loc)
			var new_action:ACTION = EncounterActionAnchor.new(ENGINE, TARGET, tile)
			ENGINE.NpcManager.add_state(new_action)

			new_action = EncounterActionNode.new(ENGINE, OWNER, TARGET)
			new_action.LOCATION = closest_loc

			return ["replace", new_action] # lol at having a class explicitly to start new states, and returning via a result like a schlub
		
		# seduce accepted but no valid locations turns it into a flirt

		var dialogue_string: String = OWNER.NAME + " flirted with " + TARGET.NAME
		ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, [TARGET.ID], dialogue_string)
		dialogue_string = TARGET.NAME + " was " + impression + " about being flirted with."
		ENGINE.History.add_event(TARGET.ID, "converse", TARGET.LOCATION, [OWNER.ID], dialogue_string)
		
	else:
		# seduce denied
		var dialogue_string: String = OWNER.NAME + " flirted with " + TARGET.NAME
		ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, [TARGET.ID], dialogue_string)
		dialogue_string = TARGET.NAME + " was annoyed about being flirted with."
		ENGINE.History.add_event(TARGET.ID, "converse", TARGET.LOCATION, [OWNER.ID], dialogue_string)
	return ["running", null]
	
