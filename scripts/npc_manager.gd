extends Control

class_name NPC_MANAGER

var ENGINE
var NPCS: Array[NPC]

var ID_COUNTER: int = 0

func _init(engine) -> void:
	ENGINE = engine
	z_index = -40
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
	var new_action: ACTION = IdleAction.new(ENGINE, npc, null)
	npc.STATE_STACK.append(new_action)
	
	ENGINE.History.add_event(npc.ID, "created", npc.LOCATION)




func tick() -> void:
	for npc:NPC in NPCS:
		print("ticking ", npc.NAME)
		var current_action: ACTION = npc.STATE_STACK.back()

		print(current_action)

		var result: Array = current_action.tick()

		print(result)

		if result[0] == "add":
			current_action.suspend_state()
			var new_action:ACTION = result[1]
			new_action.enter_state()
			npc.STATE_STACK.append(new_action)
		elif result[0] == "replace":
			current_action.exit_state()
			npc.STATE_STACK.pop_back()
			var new_action:ACTION = result[1]
			new_action.enter_state()
			npc.STATE_STACK.append(new_action)
		elif result[0] == "end":
			current_action.exit_state()
			npc.STATE_STACK.pop_back()
			var next_action: ACTION = npc.STATE_STACK.back()
			next_action.resume_state()
		else:
			# state continues running
			#assumes result is ["running", null]
			pass

func add_state_old(npc_id:String, new_state_id:String, params: Dictionary) -> void:
	var npc: NPC = get_npc(npc_id)
	var current_action: ACTION = npc.STATE_STACK.back()
	current_action.suspend()
	var ACTION_CLASS: GDScript = Constants.ACTION_ID[new_state_id]
	var new_action:ACTION = ACTION_CLASS.new(ENGINE, npc)
	new_action.enter_state()
	npc.STATE_STACK.append(new_action)


func add_state(new_action: ACTION) -> void:
	var npc = new_action.OWNER
	var current_action: ACTION = npc.STATE_STACK.back()
	current_action.suspend_state()
	new_action.enter_state()
	npc.STATE_STACK.append(new_action)



func update() -> void:
	# updates display, does not tick npcs
	print("z index", z_index)
	print("updating npc manager")
	for child in get_children():
		remove_child(child)
	
	for npc: NPC in NPCS:
		var x_index: int = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(int(npc.LOCATION[0]))
		if x_index < 0:
			print(Global.X_RANGE, npc.LOCATION[0])
			print("continuing")
			continue
		var y_index: int = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(int(npc.LOCATION[1]))
		if y_index < 0:
			print("continuing")
			continue

		add_child(npc)
		npc.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.MAIN_FRAME_POSITION[0] + (Constants.TILE_SIZE/2)
		npc.global_position[1] = y_index * Constants.TILE_SIZE + Constants.TILE_SIZE/2
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
		SeduceAction
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

func is_available(npc: NPC) -> bool:
	# returns whether the npc is available for interactions
	var current_action: ACTION = npc.STATE_STACK.back()
	var nonconcurrent_actions: Array[RefCounted] = [
		#EnergyAction,
		#HungerAction, # not sure if i want this interruptable or not
		MoveAction, # i'll update this eventually
		BladderAction,
		EncounterActionAnchor,
		EncounterActionNode,
	]
	if current_action in nonconcurrent_actions: #have no idea if this will work
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

#endregion utility
