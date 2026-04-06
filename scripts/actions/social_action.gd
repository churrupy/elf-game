class_name SocialAction extends ACTION


func _init(engine, owner: NPC, target: NPC) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "converse"
	super._init(engine, owner, target)

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

func tick() -> Array:
	var res:Array = ["running", null]
	if !can_do_action():
		res = ["end", null]
	elif OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
		var new_action: ACTION = ChangingMoveAction.new(ENGINE, OWNER, TARGET, ID)
		res = ["add", new_action]
	else:
		res = run()
	OWNER.decay_needs()
	return res

func run() -> Array:
	
	#print("*************", PHYSICAL_ACTION)
	flirt()

	var res: Array = ["running", null]

	var nearby_npcs:Array[String] = ENGINE.NpcManager.get_nearby_npcs(OWNER.LOCATION)
	if len(nearby_npcs) > 0:
		chitchat() # refresh needs already covered in this
	# have some kind of "if attracted to, then flirt" here

	COUNTDOWN -= 1
	if COUNTDOWN < 0 or !ENGINE.NpcManager.is_available(TARGET):
		return ["end", null]
	return res

'''
func flirt() -> void:
	# deal with being target of escalation
	var nodes:Array[String] = get_nodes()
	if len(nodes) > 0:
		# target
		# right now just assume that being targeted automatically means escalation
		# i'll figure out the details later
		for node:String in nodes:
			# decide whether to rebuff them
			var attraction:int = ENGINE.NpcManager.get_attraction(OWNER.ID, node)
			if attraction < 0:
				ENGINE.History.add_event(OWNER.ID, "rebuff", node)
	
	if PHYSICAL_ACTION != "":
		if OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
			# target moved away
			TARGET = null
		var event_index:int = ENGINE.History.does_event_exist(TARGET.ID, "rebuff", OWNER.ID)
		if event_index < 0:
			PHYSICAL_ACTION == ""
		else:
			# try to escalate
			if PHYSICAL_ACTION in Dialogue.ENCOUNTER_ESCALATION:
				PHYSICAL_ACTION = Dialogue.ENCOUNTER_ESCALATION[PHYSICAL_ACTION]
				ENGINE.History.add_event(OWNER.ID, PHYSICAL_ACTION, TARGET.ID)

	elif (OWNER.NEEDS["release"] < 50 or OWNER.NEEDS["arousal"] > 30):
		if TARGET != NPC:
			var nearby_npcs:Array[String] = ENGINE.NpcManager.get_nearby_npcs(OWNER.LOCATION)
			var highest_attraction: int = 0
			var most_attractive_npc:String
			for npc_id:String in nearby_npcs:
				#var npc:NPC = Global.NPCS[npc_id]
				var attraction:int = ENGINE.NpcManager.get_attraction(OWNER.ID, npc_id)
				if attraction > highest_attraction:
					var event_index:int = ENGINE.History.does_event_exist(npc_id, "rebuff", OWNER.ID) #assumes that target npc will never change their mind (though i really should put expiration dates on the events lol)
					highest_attraction = attraction
					most_attractive_npc = npc_id
			if most_attractive_npc != null:
				TARGET = Global.NPCS[most_attractive_npc]
		else:
			# let's start with this
			PHYSICAL_ACTION = "sweet nothings"
			ENGINE.History.add_event(OWNER.ID, PHYSICAL_ACTION, TARGET.ID)


'''

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
	
