# class_name ActionDeterminator extends Object

# '''
# sequence is RUNNING or FAILURE
# fallback is RUNNING or SUCCESS

# RUNNING means to continue through the tree
# FAILURE on sequence means to do the fail action until succeeding
# SUCCESS on sequence means to do the succeeding action until completion
# '''

# var ENGINE

# enum STATUS {
# 	RUNNING,
# 	FAILURE,
# 	SUCCESS
# }


# func _init(engine) -> void:
# 	ENGINE = engine

# func determine_next_action(npc:NPC) -> STATUS:
# 	# all leaf nodes should push an action onto the stack
# 	# this should only ever return STATUS.RUNNING
# 	# i should probably fix that at some point but WHATEVERRRRR
# 	# sequence
# 	var node_list: Array[Callable] = [
# 		urgent_needs_filled_sequence,
# 		nonurgent_needs_filled_fallback
# 	]
# 	for node: Callable in node_list:
# 		#print("calling", node)
# 		var status: STATUS = node.call(npc)
# 		if status != STATUS.SUCCESS: return status
# 	return STATUS.SUCCESS

# #region urgent

# func urgent_needs_filled_sequence(npc:NPC) -> STATUS:
# 	var node_list:Array[Callable] = [
# 		fill_bladder,
# 		fill_hunger
# 	]

# 	for node:Callable in node_list:
# 		var status:STATUS = node.call(npc)
# 		if status != STATUS.SUCCESS: return status
# 	return STATUS.SUCCESS

# func fill_bladder(npc:NPC) -> STATUS:
# 	print("checking bladder")
# 	if npc.NEEDS["bladder"] > 50:
# 		return STATUS.SUCCESS

# 	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag("fill_bladder").is_available()
# 	var toilets:Array[TILE] = filter.run_filter()
# 	if len(toilets) == 0:
# 		# no available toilets
# 		# wait until a toilet opens up
# 		# can still converse, but won't do anything else until a toilet is free
# 		return STATUS.RUNNING

# 	toilets.sort_custom(func(a,b): npc.LOCATION.distance_to(b.LOCATION) < npc.LOCATION.distance_to(a.LOCATION))
# 	var chosen_toilet:TILE = toilets[0]
# 	print("chosen location: ", chosen_toilet.LOCATION)
	
# 	var new_action:BladderAction = BladderAction.new(ENGINE, npc, chosen_toilet)
# 	ENGINE.NpcManager.add_state(new_action)
# 	return STATUS.RUNNING

	
# func fill_hunger(npc:NPC) -> STATUS:
# 	print("checking hunger")
# 	if npc.NEEDS["hunger"] > 50:
# 		return STATUS.SUCCESS

# 	var filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().has_tag("food").in_range_of(npc.LOCATION, 10).include_owner(npc)
# 	var food_locations:Array[INVENTORY] = filter.run_filter()
# 	print(food_locations)
# 	# if len(food_locations) == 0:
# 	# 	#probably leave site
# 	# 	return STATUS.RUNNING

# 	food_locations.sort_custom(func(a,b): npc.LOCATION.distance_to(b.OWNER.LOCATION) < npc.LOCATION.distance_to(a.OWNER.LOCATION))
# 	for loc:INVENTORY in food_locations:
# 		var interactable_location:Vector2 = ENGINE.Map.get_closest_interactable_location(npc.LOCATION, loc.OWNER)
# 		if interactable_location != Vector2.INF:
# 			var new_action:HungerAction = HungerAction.new(ENGINE, npc, loc.OWNER)
# 			new_action.LOCATION = interactable_location
# 			ENGINE.NpcManager.add_state(new_action)
# 			return STATUS.RUNNING

# 	# probably leave site at this point
# 	return STATUS.RUNNING
	

# #endregion urgent


# #region nonurgent
# func nonurgent_needs_filled_fallback(npc:NPC) -> STATUS:
# 	var node_list: Array[Callable] = [
# 		fill_fun_action,
# 		fill_social_action
# 	]

# 	for node:Callable in node_list:
# 		var status = node.call(npc)
# 		if status != STATUS.FAILURE: return status
# 	return STATUS.FAILURE

# func fill_fun_action(npc:NPC) -> STATUS:
# 	print("checking fun")
# 	if npc.NEEDS["fun"] > 50:
# 		return STATUS.FAILURE
# 	return fill_fun_action_old(npc)

# func fill_fun_action_old(npc:NPC) -> STATUS:
# 	# they all just dance for now, figure out the details later
# 	var action_locations: Array[Vector2] = ENGINE.Map.find_action_locations("dance")
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
# 	var new_action = DanceAction.new(ENGINE, npc, tile)
# 	print(new_action)
# 	print(npc)
# 	#var new_action = MoveAction.new(ENGINE, npc, tile, action)
# 	#ENGINE.NpcManager.print_state(new_action)
# 	ENGINE.NpcManager.add_state(new_action)
# 	#print("adding move action")
# 	return STATUS.RUNNING

# func fill_social_action(npc:NPC) -> STATUS:
# 	print("checking social")
# 	return STATUS.RUNNING
	


# #endregion nonurgent
 
