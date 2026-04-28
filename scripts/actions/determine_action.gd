class_name ActionDeterminator extends Object

'''
sequence is RUNNING or FAILURE
fallback is RUNNING or SUCCESS

RUNNING means to continue through the tree
FAILURE on sequence means to do the fail action until succeeding
SUCCESS on sequence means to do the succeeding action until completion
'''

var ENGINE

enum STATUS {
	RUNNING,
	FAILURE,
	SUCCESS
}


func _init(engine) -> void:
	ENGINE = engine

func determine_next_action(npc:NPC) -> STATUS:
	# all leaf nodes should push an action onto the stack
	# this should only ever return STATUS.RUNNING
	# i should probably fix that at some point but WHATEVERRRRR
	# fallback
	var node_list: Array[Callable] = [
		urgent_needs_filled_sequence,
		nonurgent_needs_filled_fallback
	]
	for node: Callable in node_list:
		#print("calling", node)
		var status: STATUS = node.call(npc)
		if status != STATUS.FAILURE: return status
	return STATUS.FAILURE

#region urgent

func urgent_needs_filled_sequence(npc:NPC) -> STATUS:
	var need_list: Array[String] = [
		"bladder", 
		"hunger", 
		#"energy"
	]
	for need: String in need_list:
		#var status = decide_refresh_needs_fallback(npc, need)
		var status = refresh_needs(npc, need)
		if status != STATUS.SUCCESS: return status
	return STATUS.SUCCESS

func refresh_needs(npc:NPC, need:String) -> STATUS:
	if npc.NEEDS[need] > 50:
		return STATUS.SUCCESS
	#print("need is urgent: ", need)

	var action_dict: Dictionary = {
		"bladder": BladderAction,
		"hunger": HungerAction,
		#"energy": EnergyAction
	}
	
	var new_action = action_dict[need].new(ENGINE, npc, null)
	ENGINE.NpcManager.add_state(new_action)
	return STATUS.RUNNING


# func decide_refresh_needs_fallback(npc:NPC, need:String) -> STATUS:
# 	var node_list: Array[Callable] = [
# 		need_urgent_cond,
# 		#fill_need_sequence
# 		fill_need_action
# 	]

# 	for node:Callable in node_list:
# 		var status = node.call(npc,need)
# 		if status != STATUS.FAILURE: return status
# 	return STATUS.FAILURE

# func need_urgent_cond(npc:NPC, need:String) -> STATUS:
# 	if npc.NEEDS[need] > 50:
# 		return STATUS.SUCCESS
# 	print("need is urgent: ", need)
# 	return STATUS.FAILURE

# func fill_need_action(npc:NPC, need:String) -> STATUS:
# 	var action_dict: Dictionary = {
# 		"bladder": BladderAction,
# 		"hunger": HungerAction,
# 		#"energy": EnergyAction
# 	}

# 	var new_action = action_dict[need].new(ENGINE, npc, null)
# 	ENGINE.NpcManager.add_state(new_action)
# 	return STATUS.RUNNING

# func fill_need_action_old(npc:NPC, need:String) -> STATUS:
# 	var action_dict: Dictionary = {
# 		"bladder": BladderAction,
# 		"hunger": HungerAction,
# 		#"energy": EnergyAction
# 	}
# 	var action_locations: Array[Vector2] = ENGINE.Map.find_action_locations(need)
# 	var smallest_distance: float = 100
# 	var closest_location: Vector2 = Vector2.INF
# 	for loc: Vector2 in action_locations:
# 		var distance: float = npc.LOCATION.distance_to(loc)
# 		if distance <= smallest_distance:
# 			smallest_distance = distance
# 			closest_location = loc
# 	if closest_location == Vector2.INF:
# 		print("no valid tile found")
# 		return STATUS.FAILURE
# 	var tile:TILE = ENGINE.Map.get_tile(closest_location)
# 	var new_action = action_dict[need].new(ENGINE, npc, tile)
# 	# print(new_action)
# 	# print(npc)
# 	#var new_action = MoveAction.new(ENGINE, npc, tile, action)
# 	#ENGINE.NpcManager.print_state(new_action)
# 	ENGINE.NpcManager.add_state(new_action)
# 	#print("adding move action")
# 	return STATUS.RUNNING

#endregion urgent


#region nonurgent
func nonurgent_needs_filled_fallback(npc:NPC) -> STATUS:
	var node_list: Array[Callable] = [
		fill_fun_action,
		fill_social_action
	]

	for node:Callable in node_list:
		var status = node.call(npc)
		if status != STATUS.FAILURE: return status
	return STATUS.FAILURE

func fill_fun_action(npc:NPC) -> STATUS:
	if npc.NEEDS["fun"] > 50:
		return STATUS.FAILURE
	return fill_fun_action_old(npc)

func fill_fun_action_old(npc:NPC) -> STATUS:
	# they all just dance for now, figure out the details later
	var action_locations: Array[Vector2] = ENGINE.Map.find_action_locations("dance")
	var smallest_distance: float = 100
	var closest_location: Vector2 = Vector2.INF
	for loc: Vector2 in action_locations:
		var distance: float = npc.LOCATION.distance_to(loc)
		if distance <= smallest_distance:
			smallest_distance = distance
			closest_location = loc
	if closest_location == Vector2.INF:
		print("no valid tile found")
		return STATUS.FAILURE
	var tile:TILE = ENGINE.Map.get_tile(closest_location)
	var new_action = DanceAction.new(ENGINE, npc, tile)
	print(new_action)
	print(npc)
	#var new_action = MoveAction.new(ENGINE, npc, tile, action)
	#ENGINE.NpcManager.print_state(new_action)
	ENGINE.NpcManager.add_state(new_action)
	#print("adding move action")
	return STATUS.RUNNING

func fill_social_action(npc:NPC) -> STATUS:
	return STATUS.RUNNING
	


#endregion nonurgent
 
