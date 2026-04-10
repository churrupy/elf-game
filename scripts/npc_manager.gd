extends Control

class_name NPC_MANAGER

var ENGINE
var NPCS: Array[NPC]
var Determinator: ActionDeterminator

var ID_COUNTER: int = 0

func _init(engine) -> void:
	ENGINE = engine
	Determinator = ActionDeterminator.new(ENGINE)
	for i: int in Constants.NUM_NPCS:
		create_npc()
	
	
	

func create_npc() -> void:
	var npc: NPC = NPC.new()
	var passable_locations: Array[Vector2] = ENGINE.Map.filter_passable_locations()
	#var tile: TILE = ENGINE.Map.random_empty_tile()
	npc.LOCATION = passable_locations.pick_random()
	npc.initialize(ID_COUNTER)
	ID_COUNTER += 1
	NPCS.append(npc)
	Global.NPCS[npc.ID] = npc
	
	# initialize state stack
	var new_action: ACTION = IdleAction.new(ENGINE, npc, null, Determinator)
	npc.STATE_STACK.append(new_action)
	npc.SOCIAL_ACTION = SocialAction_new.new(ENGINE, npc)
	
	#ENGINE.History.add_event(npc.ID, "created", npc.LOCATION)

func tick_new() -> void:
	for npc:NPC in NPCS:
		print ("ticking ", npc.NAME)

		if npc.CURRENT_ACTION == null:
			Determinator.determine_next_action(npc)
		else:
			var action_result = npc.CURRENT_ACTION.tick()
			if action_result == "finish":
				npc.CURRENT_ACTION = null

		var _res: ActionResult = npc.SOCIAL_ACTION.run()
		
		npc.decay_needs()

func tick() -> void:
	for npc:NPC in NPCS:
		print ("ticking: ", npc.NAME)


		var current_action: ACTION = npc.STATE_STACK.back()
		print (current_action)

		var result: ActionResult = current_action.tick()
		print(result)

		if result.STATUS == "add":
			current_action.suspend_state()
			result.NEW_ACTION.enter_state()
			#var new_action:ACTION = result[1]
			#new_action.enter_state()
			npc.STATE_STACK.append(result.NEW_ACTION)
		elif result.STATUS == "replace":
			current_action.exit_state()
			npc.STATE_STACK.pop_back()
			#var new_action:ACTION = result[1]
			#new_action.enter_state()
			result.NEW_ACTION.enter_state()
			npc.STATE_STACK.append(result.NEW_ACTION)
		elif result.STATUS == "end":
			current_action.exit_state()
			npc.STATE_STACK.pop_back()
			var old_action:ACTION = npc.STATE_STACK[-1]
			old_action.resume_state()
			'''
			var new_action:ACTION = current_action.exit_state()
			
			npc.STATE_STACK.pop_back()
			if new_action != null:
				new_action.enter_state()
				npc.STATE_STACK.append(new_action)
			else:
				var next_action: ACTION = npc.STATE_STACK.back()
				next_action.resume_state()
			'''				
		else:
			# state continues running
			#assumes result is ["running", null]
			pass
		if current_action.CHATTABLE:
			var _res: ActionResult = npc.SOCIAL_ACTION.run()
		#npc.decay_needs()


func tick_old() -> void:
	for npc:NPC in NPCS:
		print("ticking ", npc.NAME)

		process_events(npc)

		var current_action: ACTION = npc.STATE_STACK.back()

		print(current_action)

		var result: ActionResult = current_action.tick()

		print(result)

		if result.STATUS == "add":
			current_action.suspend_state()
			result.NEW_ACTION.enter_state()
			#var new_action:ACTION = result[1]
			#new_action.enter_state()
			npc.STATE_STACK.append(result.NEW_ACTION)
		elif result.STATUS == "replace":
			current_action.exit_state()
			npc.STATE_STACK.pop_back()
			#var new_action:ACTION = result[1]
			#new_action.enter_state()
			result.NEW_ACTION.enter_state()
			npc.STATE_STACK.append(result.NEW_ACTION)
		elif result.STATUS == "end":
			var new_action:ACTION = current_action.exit_state()
			npc.STATE_STACK.pop_back()
			if new_action != null:
				new_action.enter_state()
				npc.STATE_STACK.append(new_action)
			else:
				var next_action: ACTION = npc.STATE_STACK.back()
				next_action.resume_state()
		else:
			# state continues running
			#assumes result is ["running", null]
			pass


func process_events(npc:NPC) -> void:
	for event:HistoryEvent in npc.EVENT_QUEUE:
		var reaction: int
		if event.ACTOR not in npc.RELATIONSHIPS:
			npc.RELATIONSHIPS[event.ACTOR] = 0
		#var actor_opinion = npc.RELATIONSHIPS[event.ACTOR]
		if event.ACTION_ID == "converse":
			var topic:String = event.PARAM["topic"]
			var actor_opinion = event.PARAM["opinion"]
			var npc_opinion:int = npc.OPINIONS[topic]
			var diff:int = abs(actor_opinion - npc_opinion)
			if diff < 2: reaction = 1
			elif diff < 4: reaction = 0
			else: reaction = -1
			npc.RELATIONSHIPS[event.ACTOR] += reaction
		elif event.ACTION_ID == "flirt":
			if event.TARGET == npc.ID:
				var attraction: int = get_attraction(event.TARGET, event.ACTOR)
				if attraction > 0:
					reaction = 1
				elif attraction == 0:
					reaction = 0
				else:
					reaction = -1
			else:
				reaction = 0
		ENGINE.History.add_reaction(npc.ID, reaction, event)
		if event.TARGET == npc.ID:
			# npc is target and broadcasts reaction
			var action:String
			var action_list: Dictionary = {
				1: "accepts",
				0: "indifferent",
				-1: "rejects"
			}

			#ENGINE.History.add_event(npc.ID, action_list[reaction], event.ACTOR)

	npc.EVENT_QUEUE = [] # clear queue




func add_state_old(npc_id:String, new_state_id:String, params: Dictionary) -> void:
	var npc: NPC = get_npc(npc_id)
	var current_action: ACTION = npc.STATE_STACK.back()
	current_action.suspend()
	var ACTION_CLASS: GDScript = Constants.ACTION_ID[new_state_id]
	var new_action:ACTION = ACTION_CLASS.new(ENGINE, npc)
	new_action.enter_state()
	npc.STATE_STACK.append(new_action)


func add_state(new_action:ACTION) -> void:
	print(new_action)
	var npc = new_action.OWNER
	var current_action: ACTION = npc.STATE_STACK.back()
	current_action.suspend_state()
	new_action.enter_state()
	npc.STATE_STACK.append(new_action)

func add_state_new(new_action: ACTION) -> void:
	var npc = new_action.OWNER
	npc.CURRENT_ACTION = new_action

func update() -> void:
	# updates display, does not tick npcs
	print("updating npc manager")
	for child in get_children():
		remove_child(child)
	
	for npc: NPC in NPCS:
		var x_index: int = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(int(npc.LOCATION[0]))
		if x_index < 0:
			continue
		var y_index: int = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(int(npc.LOCATION[1]))
		if y_index < 0:
			continue

		add_child(npc)
		npc.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.CENTER_PANEL_LOCATION[0]
		npc.global_position[1] = y_index * Constants.TILE_SIZE
		npc.global_position = npc.global_position + Vector2(Constants.TILE_SIZE/2, Constants.TILE_SIZE/2)
		npc.show()


#region filters
func filter_reserved_locations(loc_list: Array[Vector2]) -> Array[Vector2]:
	var free_loc: Array[Vector2]
	for loc: Vector2 in loc_list:
		if is_reserved(loc): continue
		free_loc.append(loc)
	return free_loc


#endregion filters
		


#region utility
func get_npc(npc_id:String) ->NPC:
	for npc:NPC in NPCS:
		if npc_id == npc.ID:
			return npc
	return null

func get_all_npc_actions(checked_npc: NPC) -> Array[ACTION]:
	var action_classes: Array[RefCounted] = [
		SocialAction, 
		#"FlirtAction", 
		#SeduceAction
	]
	var all_actions: Array[ACTION]
	for npc_id: String in Global.NPCS.keys():
		if npc_id == checked_npc.ID: continue
		var npc:NPC = Global.NPCS[npc_id]
		if !is_available(npc): continue
		for ACTION_CLASS:RefCounted in action_classes:
			#var ACTION_CLASS: GDScript = Constants.ACTION_ID[action_class_id]
			var new_action: ACTION = ACTION_CLASS.new(ENGINE, checked_npc, npc)
			all_actions.append(new_action)
	return all_actions

func get_attraction(npc_id:String, target_npc_id:String) -> int:
	return 1 # for testing
	var npc:NPC = Global.NPCS[npc_id]
	var target_npc:NPC = Global.NPCS[target_npc_id]
	var attraction:int = npc.OPINIONS[target_npc.STYLE]
	print("$$$$$$$$$$$$$$$$$", attraction)
	return attraction
	#return npc.OPINIONS[target_npc.STYLE]
	#var other_style = other_npc.STYLE
	#return OPINIONS[other_style]

func is_available(npc: NPC) -> bool:
	# returns whether the npc is available for interactions
	var current_action: ACTION = npc.STATE_STACK.back()
	var current_action_id: String = current_action.ID
	if current_action_id == "move":
		current_action_id = current_action.MOVING_FOR
	var busy_actions: Array[String] = [
		"use toilet",
		"encounter"
	]
	if current_action_id in busy_actions: #have no idea if this will work
		return false
	return true


func is_reserved(location: Vector2) -> bool:
	for npc:NPC in NPCS:
		var current_action:ACTION = npc.STATE_STACK.back()
		if current_action.LOCATION == location:
			return true
	return false


func get_nearby_npcs(location: Vector2) -> Array[String]:
	var nearby_npcs: Array[String]
	for npc: NPC in NPCS:
		if int(npc.LOCATION[0]) not in range(location[0]-1, location[0]+2): continue
		if int(npc.LOCATION[1]) not in range(location[1]-1, location[1]+2): continue
		nearby_npcs.append(npc.ID)
	return nearby_npcs

func get_conversation_partners(npc:NPC) -> Array[String]:
	var nearby_npcs: Array[String] = get_nearby_npcs(npc.LOCATION)
	var npc_index: int = nearby_npcs.find(npc.ID)
	if npc_index > -1:
		nearby_npcs.pop_at(npc_index)
	return nearby_npcs

#endregion utility
