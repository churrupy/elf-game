class_name SeduceAction extends ACTION

func _init(engine, owner: NPC, target: NPC) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "seduce"
	super._init(engine, owner, target)

func can_do_action() -> bool:
	return ENGINE.NpcManager.is_available(TARGET)






func score() -> void:
	
	var need: int = OWNER.NEEDS["release"]
	SCORE += 100 - need
	
	# score based on preference
	if OWNER == TARGET:
		SCORE = -100
		return
	SCORE += get_opinion()
	SCORE += get_attraction()

	var closest_location: Vector2 = ENGINE.Map.get_closest_adjacent_location(OWNER.LOCATION, TARGET.LOCATION)
	if closest_location == Vector2.INF:
		SCORE = -100
		return
	LOCATION = closest_location


func tick() -> ActionResult:
	if !can_do_action():
		return ActionResult.new("end", null)
		#return ["end", null]
	if OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
		#var closest_location: Vector2 = ENGINE.Map.get_closest_adjacent_location(OWNER.LOCATION, TARGET.LOCATION)
		#var tile: TILE = ENGINE.Map.get_tile(closest_location)
		var new_action: ACTION = ChangingMoveAction.new(ENGINE, OWNER, TARGET, ID)
		return ActionResult.new("add", new_action)
		#return ["add", new_action]
	
	var result: ActionResult = run()
	OWNER.decay_needs()
	return result


func run() -> ActionResult:
	# target hears flirt
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

			return ActionResult.new("replace", new_action)
			#return ["replace", new_action] # lol at having a class explicitly to start new states, and returning via a result like a schlub
		
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
	
	return ActionResult.new("end", null)
	#return ["end", null]
