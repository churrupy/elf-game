class_name NPC_MANAGER extends Control

var ENGINE
var NPCS: Array[NPC]
#var Determinator: ActionDeterminator

func _init(engine, num_npcs:int) -> void:
	ENGINE = engine
	#Determinator = ActionDeterminator.new(ENGINE)
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
	
	# initialize npc goal stack
	var idle_goal:ACTION = IdleGoal.new(ENGINE, npc, null)
	npc.ACTION_STACK.append(idle_goal)

#region tick

func tick() -> void:
	for npc:NPC in NPCS:
		print("")
		print ("***** ", npc.NAME, " *****")
		npc.decay_needs()
		# print("goals:", npc.ACTION_STACK)

		var continuing:bool = true
		var PANIC:int = 0

		while continuing:
			print("")
			print("action attempt: ", PANIC)
			PANIC += 1
			if PANIC >= 10:
				print("PANICKING!")
				break
			continuing = false
			print("action stack:", npc.ACTION_STACK)
			var current_action:ACTION = npc.ACTION_STACK.back()
			print("current action: ", current_action)
			var res:ActionResult = current_action.run()
			print(res, current_action.STATUS)

			if res.STATUS == "success":
				var index:int = npc.ACTION_STACK.find(current_action)
				if index > -1:
					npc.ACTION_STACK.remove_at(index)
				continuing = true
			elif res.STATUS == "end":
				current_action.end_action()
				var index:int = npc.ACTION_STACK.find(current_action)
				if index > -1:
					npc.ACTION_STACK.remove_at(index)
				continuing = true
			# if res.STATUS == "success":
			# 	npc.ACTION_STACK.pop_back()
			# 	continuing = true
			elif res.STATUS == "fail":
				var idle_action:ACTION = npc.ACTION_STACK[0]
				npc.ACTION_STACK = [idle_action]
				continuing = true
			elif res.STATUS == "continue":
				continuing = true
			elif res.STATUS == "running":
				pass
			elif res.STATUS == "recalculate":
				# cya contigency if system can't figure out an appropriate action to do
				# clears action stack, waits for five rounds, and tries again
				var idle_action:ACTION = npc.ACTION_STACK[0]
				npc.ACTION_STACK = [idle_action]
				for i in range(0,5):
					idle_action.add_action(WaitAction)


		print(npc.NAME, " finished processing")

	# validate_npc_locations()


		
		
func validate_npc_locations() -> void:
	print("validating npc locations")
	for npc:NPC in NPCS:
		var filtered_npcs:Array[NPC] = NPC_FILTER.new(ENGINE).set_list().set_location(npc.LOCATION).run_filter()
		if len(filtered_npcs) > 1:
			print("colliding npcs")
			var moving_npcs:Array[NPC] = NPC_FILTER.new(ENGINE).set_list(filtered_npcs).set_action_id("move").run_filter()
			var moving_npc:NPC
			if len(moving_npcs) == 1:
				# if only one npc that is actively moving, then they get priority on the space
				print("only one moving npc")
				moving_npc = moving_npcs[0]
			for checked_npc:NPC in filtered_npcs:
				if checked_npc == moving_npc: continue
				var tile_list:Array[TILE]
				var current_room:ROOM = ENGINE.Map.get_room(checked_npc.LOCATION)
				if checked_npc.GOAL_STACK.back().ID == "shoo":
					# if being kicked out try, to find a location outside of the room they're currently in
					tile_list = TILE_FILTER.new(ENGINE).set_list().in_range_of(checked_npc.LOCATION, 1.5).is_passable().is_available().set_not_room(current_room).run_filter()	
				else:
					# else try to keep them in the same room
					tile_list = TILE_FILTER.new(ENGINE).set_list().in_range_of(checked_npc.LOCATION, 1.5).is_passable().is_available().set_room(current_room).run_filter()
				
				# but if that fails, then don't filter by rooms
				if len(tile_list) == 0:
					tile_list = TILE_FILTER.new(ENGINE).set_list().in_range_of(checked_npc.LOCATION, 1.5).is_passable().is_available().run_filter()
				# var tile_list:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().in_range_of(checked_npc.LOCATION, 1.5).is_passable().is_available().run_filter()
				if len(tile_list) > 0:
					checked_npc.LOCATION = tile_list.pick_random().LOCATION
					print(npc.NAME, " gets pushed to ", npc.LOCATION)





func clear_actions(_npc:NPC) -> void:
	print("clearing ", _npc.NAME, "'s actions")
	var idle_action:ACTION = _npc.ACTION_STACK[0]
	_npc.ACTION_STACK = [idle_action]

#endregion tick


#region update

func update() -> void:
	# updates display, does not tick npcs
	print("updating npc manager")
	for child in get_children():
		remove_child(child)
	
	for npc: NPC in NPCS:

		# highlight reserved tile
		# var current_action: ACTION = npc.STATE_STACK.back()
		# var reserved_loc: Vector2 = current_action.LOCATION
		# if reserved_loc != Vector2.INF:
		# 	#print(reserved_loc)
		# 	ENGINE.Map.highlight_tile(reserved_loc, npc.HAIR_COLOR)
		# # else:
		# 	# print("infinite vector")

		#if npc.GOAL_ACTION != null:
			#var reserved_loc:Vector2 = npc.GOAL_ACTION.LOCATION
			#ENGINE.Map.highlight_tile(reserved_loc, npc.HAIR_COLOR)

		var global_location:Vector2 = ENGINE.GameWindow.get_global_location(npc.LOCATION)
		if global_location[0] < 0 or global_location[1] < 0:
			continue
		
		# adjust to make sure tile ends up in center panel
		global_location += Vector2(ENGINE.GameWindow.CENTER_PANEL_LOCATION[0], 0)
		global_location += ENGINE.GameWindow.TILE_CENTER
		# global_location[0] = global_location[0] + ENGINE.GameWindow.CENTER_PANEL_LOCATION[0]
		add_child(npc)
		npc.position = global_location
		

		# var x_index: int = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(int(npc.LOCATION[0]))
		# if x_index < 0:
		# 	continue
		# var y_index: int = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(int(npc.LOCATION[1]))
		# if y_index < 0:
		# 	continue

		# add_child(npc)
		# npc.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.CENTER_PANEL_LOCATION[0]
		# npc.global_position[1] = y_index * Constants.TILE_SIZE
		# npc.global_position = npc.global_position + Vector2(Constants.TILE_SIZE/2, Constants.TILE_SIZE/2)
		# npc.show()

		# draws line between npc and the other npcs it can see (that are close by)
		# does not show ALL other npcs an npc can see, just the close ones
		var filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list(NPCS).in_range_of(npc.LOCATION, 2).in_arc_of(npc.DIRECTION)
		var can_see_npcs:Array[NPC] = filter.run_filter()
		npc.LOOKING_AT = []
		for checked_npc:NPC in can_see_npcs:
			npc.LOOKING_AT.append(checked_npc.LOCATION)
		npc.queue_redraw()


		
	#print_reserved_locations()

#endregion update

#region filters
func is_reserved(location:Vector2) -> bool:
	var npc_filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_location(location)
	var filtered_npcs:Array[NPC] = npc_filter.run_filter()
	if len(filtered_npcs) > 0:
		return true
	return false


func print_reserved_locations() -> void:
	for npc:NPC in NPCS:
		var current_action:ACTION = npc.STATE_STACK.back()
		print(ENGINE.prettify_vector(current_action.LOCATION))

func get_reserved_locations() -> Array[Vector2]:
	var result_list:Array[Vector2]
	for npc:NPC in NPCS:
		if npc.GOAL_ACTION != null:
			result_list.append(npc.get_reserved_location())
	return result_list


#endregion filters
		


#region utility
func get_npc(npc_id:String) ->NPC:
	for npc:NPC in NPCS:
		if npc_id == npc.ID:
			return npc
	return null


func generate_title(npc_id:String) -> String:
	var npc:NPC = get_npc(npc_id)
	return npc.NAME

#func generate_navlist(npc_id:String = "NPCS") -> Array[String]:
	#var return_string:Array[String]
	#if npc_id == "NPCS":
		#return return_string.assign(["All"])
	#else:
		#return return_string.assign(["All", "NPCS"])
#
#func generate_journal_entry(npc_id:String, subentry:String = "details") -> Array:
	#var return_list:Array
	#var npc:NPC = get_npc(npc_id)
	#return_list.append(npc.generate_general())
#
	#var subnav_list:Dictionary[String, Callable] = {
		#"needs": ENGINE.NpcManager.generate_needs_subentry,
		#"relationships": ENGINE.NpcManager.generate_relationships_subentry,
		#"inventory": ENGINE.InventoryManager.generate_inventory_subentry
	#}
#
	#return_list.append(ENGINE.MenuBones.create_subnav(subnav_list.keys()))
#
	#return_list += subnav_list[subentry].call(npc_id)
#
	#return return_list



#endregion utility


#region convert
func get_npc_names(npc_list:Array[NPC]=NPCS) -> Array[String]:
	# HUH BLUH BLUH HOW DOES ECS WORK BLU BLUH
	var result_list:Array[String]
	for npc:NPC in npc_list:
		result_list.append(npc.NAME)
	return result_list

#endregion

func get_npcs_from_ids(id_list:Array[String]) -> Array[NPC]:
	var npc_list:Array[NPC]
	for id:String in id_list:
		var npc:NPC = get_npc(id)
		npc_list.append(npc)
	return npc_list
