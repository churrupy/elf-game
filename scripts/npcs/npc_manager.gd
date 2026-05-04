extends Control

class_name NPC_MANAGER

var ENGINE
var NPCS: Array[NPC]
var Determinator: ActionDeterminator

func _init(engine, num_npcs:int) -> void:
	ENGINE = engine
	Determinator = ActionDeterminator.new(ENGINE)
	for i: int in num_npcs:
		create_npc()
	
	
func _process(_delta: float) -> void:
	pass

func create_npc() -> void:
	var npc: NPC = NPC.new()
	#var passable_locations: Array[Vector2] = ENGINE.Map.filter_passable_locations()

	# I want to use this one VVV but NpcManager isn't finished being constructed when being called, so maybe i'll figure out somehow to get around that
	#var loc_filter:LOCATION_FILTER = LOCATION_FILTER.new(ENGINE).set_list().is_passable().is_available()
	var loc_filter:LOCATION_FILTER = LOCATION_FILTER.new(ENGINE).set_list().is_passable()
	var filtered_locations:Array[Vector2] = loc_filter.run_filter()


	npc.LOCATION = filtered_locations.pick_random()
	npc.initialize()
	NPCS.append(npc)
	Global.NPCS[npc.ID] = npc
	ENGINE.InventoryManager.create_inventory(npc)
	ENGINE.GroupManager.create_group(npc)
	
	# initialize state stack
	var new_action: ACTION = IdleAction.new(ENGINE, npc, null, Determinator)
	npc.STATE_STACK.append(new_action)
	npc.SOCIAL_ACTION = SocialAction_new.new(ENGINE, npc)



func tick() -> void:
	for npc:NPC in NPCS:
		print("")
		print ("***** ", npc.NAME, " *****")
		#print_reserved_locations()

		


		var current_action: ACTION = npc.STATE_STACK.back()
		print ("current_action: ", current_action)

		var result: ActionResult = current_action.tick()
		#print(result)

		if result.STATUS == "add":
			current_action.suspend_state()
			result.NEW_ACTION.enter_state()
			npc.STATE_STACK.append(result.NEW_ACTION)

		elif result.STATUS == "replace":
			current_action.exit_state()
			npc.STATE_STACK.pop_back()
			result.NEW_ACTION.enter_state()
			npc.STATE_STACK.append(result.NEW_ACTION)

		elif result.STATUS == "end":
			current_action.exit_state()
			npc.STATE_STACK.pop_back()
			var old_action:ACTION = npc.STATE_STACK.back()
			old_action.resume_state()

		elif result.STATUS == "clear":
			current_action.exit_state()
			print("clearing " + npc.NAME + "'s actions")
			var idle_action:IdleAction = npc.STATE_STACK[0]
			npc.STATE_STACK = [idle_action]

		else:
			# state continues running
			#assumes result is ["running", null]
			pass

		# this setup seems weird lol
		current_action = npc.STATE_STACK.back()
		
		if current_action.CHATTABLE:
			var _res: ActionResult = npc.SOCIAL_ACTION.run()

		current_action = npc.STATE_STACK.back()
		print("new action: ", current_action)
		#print(npc.STATE_STACK)
		
		#npc.decay_needs()


func add_state(new_action:ACTION) -> void:
	#print(new_action)
	var npc = new_action.OWNER
	var current_action: ACTION = npc.STATE_STACK.back()
	current_action.suspend_state()
	new_action.enter_state()
	npc.STATE_STACK.append(new_action)

func update() -> void:
	# updates display, does not tick npcs
	print("updating npc manager")
	for child in get_children():
		remove_child(child)
	
	for npc: NPC in NPCS:

		# highlight reserved tile
		var current_action: ACTION = npc.STATE_STACK.back()
		var reserved_loc: Vector2 = current_action.LOCATION
		if reserved_loc != Vector2.INF:
			#print(reserved_loc)
			ENGINE.Map.highlight_tile(reserved_loc, npc.HAIR_COLOR)
		else:
			print("infinite vector")

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

		# draws line between npc and the other npcs it can see (that are close by)
		# does not show ALL other npcs an npc can see, just the close ones
		var filter:NPC_FILTER = NPC_FILTER.new().set_list(NPCS).in_range_of(npc.LOCATION, 2).in_arc_of(npc.DIRECTION)
		var can_see_npcs:Array[NPC] = filter.run_filter()
		npc.LOOKING_AT = []
		for checked_npc:NPC in can_see_npcs:
			npc.LOOKING_AT.append(checked_npc.LOCATION)
		npc.queue_redraw()


		
	#print_reserved_locations()

func broadcast_event(event:EVENT) -> void:
	var _witnesses:Array[NPC]

	if event.HEARABLE:
		var filter:NPC_FILTER = NPC_FILTER.new().set_list(NPCS).in_range_of(event.LOCATION, 2)
		var hearing_npcs:Array[NPC] = filter.run_filter()
		_witnesses += hearing_npcs
	
	if event.SEEABLE:
		var filter:NPC_FILTER = NPC_FILTER.new().set_list(NPCS).in_range_of(event.LOCATION, 10).looking_at()
		var seeing_npcs:Array[NPC] = filter.run_filter()
		_witnesses += seeing_npcs

	var witness_list:Array[NPC]
	for npc:NPC in _witnesses:
		if npc not in witness_list:
			event.process_involvement(npc)
			witness_list.append(npc)



#region filters
func filter_reserved_locations(loc_list: Array[Vector2]) -> Array[Vector2]:
	var free_loc: Array[Vector2]
	for loc: Vector2 in loc_list:
		if is_reserved(loc): continue
		free_loc.append(loc)
	return free_loc


func is_reserved(location: Vector2) -> bool:
	for npc:NPC in NPCS:
		var current_action:ACTION = npc.STATE_STACK.back()
		if current_action.LOCATION == location:
			return true
	return false

func print_reserved_locations() -> void:
	for npc:NPC in NPCS:
		var current_action:ACTION = npc.STATE_STACK.back()
		print(ENGINE.prettify_vector(current_action.LOCATION))


#endregion filters
		


#region utility
func get_npc(npc_id:String) ->NPC:
	for npc:NPC in NPCS:
		if npc_id == npc.ID:
			return npc
	return null

func get_all_npc_actions(checked_npc: NPC) -> Array[ACTION]:
	var action_classes: Array[RefCounted] = [
		#SocialAction, 
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





#region vector2


func get_nearby_npcs(location: Vector2) -> Array[String]:
	#will eventually delete this
	var nearby_npcs: Array[String]
	for npc: NPC in NPCS:
		if int(npc.LOCATION[0]) not in range(location[0]-1, location[0]+2): continue
		if int(npc.LOCATION[1]) not in range(location[1]-1, location[1]+2): continue
		nearby_npcs.append(npc.ID)
	return nearby_npcs


func get_npc_from_location(location: Vector2) -> Array[String]:
	var npc_list: Array[String]
	for npc:NPC in NPCS:
		if npc.LOCATION == location:
			npc_list.append(npc.ID)
	return npc_list

#endregion



func can_see(npc:NPC) -> Array[NPC]:
	var filter:NPC_FILTER = NPC_FILTER.new().set_list(NPCS).in_range_of(npc.LOCATION, 10).in_arc_of(npc.DIRECTION)
	var result_list:Array[NPC] = filter.run_filter()
	return result_list



#endregion utility


#region convert
func get_npc_names(npc_list:Array[NPC]=NPCS) -> Array[String]:
	# HUH BLUH BLUH HOW DOES ECS WORK BLU BLUH
	var result_list:Array[String]
	for npc:NPC in npc_list:
		result_list.append(npc.NAME)
	return result_list



#endregion
