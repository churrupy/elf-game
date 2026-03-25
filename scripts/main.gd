extends Node
class_name ENGINE

#var X_RANGE
#var Y_RANGE
@export var npc_scene: PackedScene
var History = HISTORY_CLASS.new()




var ID_COUNTER = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.tick_signal.connect(_on_tick)
	SignalBus.player_move_request.connect(process_player_move)
	
	SignalBus.npc_click.connect(open_npc_menu)
	SignalBus.close_npc_menu.connect(close_npc_menu)

	SignalBus.talk_to_npc.connect(open_talk_menu)
	SignalBus.close_talk_menu.connect(close_talk_menu)

	for i in Constants.NUM_NPCS:
		create_npc()
	$NpcMenu.hide()
	$TalkMenu.hide()
	_on_tick()



func create_npc():
	var npc = NPC.new()
	var tile = $Map.random_empty_tile()
	npc.LOCATION = tile
	npc.initialize(ID_COUNTER)
	ID_COUNTER += 1
	#add_child(npc)
	Global.NPCS[npc.ID] = npc
	History.add_entry(npc.ID, "created", npc.LOCATION)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("auto_tick"):
		_on_tick()
	
#region ticks

func process_player_move(location):
	if $Map.is_travelable(location):
		var old_location = Global.PLAYER_LOCATION.duplicate()
		Global.PLAYER_LOCATION = location
		History.add_entry("player", "moved to", old_location, {"location": location})
	else:
		print("tile not accessible")
	
	_on_tick()

func auto_tick() -> void:
	_on_tick()


func _on_move_without_tick() -> void:
	$Map.tick()
	get_current_npcs()
	#update_current_npcs()


func display_npcs():
	for child in get_children():
		if child is DISPLAYED_NPC:
			child.queue_free()
	
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]

		var x_index = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(npc.LOCATION[0])
		if x_index < 0:
			continue
		var y_index = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(npc.LOCATION[1])
		if y_index < 0:
			continue

		var displayed_npc = npc_scene.instantiate()
		displayed_npc.initialize(npc)
		add_child(displayed_npc)
		displayed_npc.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.MAIN_FRAME_POSITION[0] + Constants.TILE_SIZE/2
		displayed_npc.global_position[1] = y_index * Constants.TILE_SIZE + Constants.TILE_SIZE/2
		





func _on_tick() -> void:
	Global.X_RANGE = [Global.PLAYER_LOCATION[0] - 7, Global.PLAYER_LOCATION[0] + 8]
	Global.Y_RANGE = [Global.PLAYER_LOCATION[1] - 5, Global.PLAYER_LOCATION[1] + 6]
	

	print("")
	print("ticking...")
	Global.TICKS += 1
	print("Ticks: ", Global.TICKS)
	print("player location:", Global.PLAYER_LOCATION)
	tick_npcs()
	get_current_npcs()
	display_npcs()
	$Map.tick()
	var player_history = History.filter_by_npc("player")
	var player_history_list = History.display_history(player_history)
	$DefaultMenu.update_history_and_tick(player_history_list)
	if $NpcMenu.visible:
		# re-initialize/update visible history
		open_npc_menu($NpcMenu.DISPLAYED_NPC)
	if $TalkMenu.visible:
		open_npc_menu($TalkMenu.DISPLAYED_NPC)
	

#endregion

func get_npc_list():
	var npc_list = []
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]
		npc_list.append(npc)
	return npc_list

func get_current_npcs():
	var adjacent_locations = get_neighbors(Global.PLAYER_LOCATION)
	for l in adjacent_locations:
		Global.CURRENT_NPCS += Utility.get_npc_from_location(l)

func tick_npcs():
	Global.CURRENT_NPCS = []
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]
		print("")
		print("ticking", npc)
		#npc.tick()
		if npc.ACTION == null:
			var chosen_action = determine_action(npc)
			chosen_action.set_countdown()
			npc.ACTION = chosen_action
		npc.ACTION.update_location()
		if npc.ACTION.is_at_location(npc.LOCATION):
			npc.ACTION.STATUS = "filling"
			do_action(npc)
		else:
			var next_step = step_towards_location(npc.LOCATION, npc.ACTION.LOCATION)
			if next_step == null:
				push_error("pathfinding: no valid path found, teleporting ", npc, " to target location")
				print("teleporting...")
				print(npc.LOCATION, npc.ACTION.LOCATION)
				var old_location = npc.LOCATION.duplicate()
				npc.LOCATION = npc.ACTION.LOCATION
				History.add_entry(npc.ID, "teleported to", old_location, {"location": npc.ACTION.LOCATION})
				continue
			print(next_step)
			var old_location = npc.LOCATION.duplicate()
			'''
			var current_occupant = Utility.get_npc_from_location(next_step)
			if current_occupant != null:
				# swap locations
				# occupant should NOT be the one to reserve it because the code should check by now
				print("pushing " + current_occupant.NAME + " out of the way")
				var neighbors = get_neighbors(current_occupant.LOCATION)
				var valid_neighbors = []
				for n in neighbors:
					# makes sure that there's an empty spot (no chain pushing, that's wude)
					var neighbor_occupant = Utility.get_npc_from_location(n)
					if neighbor_occupant == null:
						valid_neighbors.append(n)
				var new_location = valid_neighbors.pick_random()

				current_occupant.LOCATION = new_location
			'''
			History.add_entry(npc.ID, "moved to", old_location, {"location": npc.ACTION.LOCATION})
			npc.LOCATION = next_step
		
		if npc.ACTION.STATUS == "finish":
			History.add_entry(npc.ID, "finished", npc.LOCATION, {"action": npc.ACTION.ID})
			npc.ACTION = null

		npc.decay_needs()
		npc.clamp_needs()
		#display_on_screen(npc, Constants.TILE_SIZE/2)

#endregion

#region npc actions

func do_action(npc):
	#npc must be at location for this function
	var action = npc.ACTION
	var witnesses = get_npcs_in_range(action.LOCATION) # same goal/location
	if len(witnesses) == 0:
		witnesses = get_npcs_in_range(npc.LOCATION) # people just "around" who can overhear

	#if action.ID == "converse":
	if action.is_conversable():
		if len(witnesses) > 1: # self is also in witnesses
			converse(npc, witnesses, npc.ACTION.TARGET) # everyone will chit-chat if they're close to someone else

	elif action.ID == "flirt":
		var dialogue_string = npc.NAME + " flirted with " + action.TARGET.NAME
		var history_params = {
			"witnesses": [action.TARGET.ID],
			"dialogue": dialogue_string
		}
		History.add_entry(npc, "converse", npc.LOCATION, history_params)
		var impression = action.TARGET.hear_flirt(npc.ID)
		dialogue_string = action.TARGET.NAME + " was " + impression + " about being flirted with."
		history_params = {
			"witnesses": [npc.ID],
			"dialogue": dialogue_string
		}
		History.add_entry(action.TARGET, "converse", action.TARGET.LOCATION, history_params)



	npc.ACTION.do(npc) # still handles need refresh, etc


func converse(npc, witnesses, location):
	var history_params = {
		"witnesses": witnesses
	}
	var new_topic = Dialogue.get_next_topic(npc.RECENT_TOPIC)
	npc.RECENT_TOPIC = new_topic
	var opinion = npc.OPINIONS[new_topic]
	var op_str = new_topic.capitalize() + " are "
	if opinion > 75:
		op_str+= "great!"
	elif opinion > 50:
		op_str += "okay."
	elif opinion > 25:
		op_str += "lame."
	else:
		op_str += "terrible!"
	var _str = npc.NAME + ': "' + op_str + '"'
	history_params["dialogue"] = _str
	History.add_entry(npc, "converse", location, history_params)
	for g in witnesses:
		if g == npc.ID:
			continue
		var g_npc = Global.NPCS[g]
		var impression = g_npc.hear_topic(npc.ID, new_topic, opinion)
		print(g_npc.NAME)
		print(impression)
		_str = g_npc.NAME + " was " + impression + " with that statement."
		print(g_npc.NAME)
		print(impression)
		history_params = {
			"witnesses": [npc.ID],
			"dialogue": _str

		}
		History.add_entry(g, "converse", location, history_params)
	





func get_npcs_in_range(location):
	# gets all npcs with the same target who are nearby
	print("get group")
	var close_npcs = []
	var target_neighbors = get_neighbors(location)
	for n in target_neighbors:
		close_npcs += Utility.get_npc_from_location(n)
	print(close_npcs)
	return close_npcs
	


#endregion


#region npc ai




func determine_action(npc):
	var all_actions = $Map.get_all_actions_on_map()
	all_actions += Utility.get_all_npc_actions()
	for action in all_actions:
		action = npc.score_action(action)

	all_actions.sort_custom(func(a, b): return b.SCORE < a.SCORE)
	for action in all_actions:
		if action.TARGET is NPC:
			# npc target
			if action.TARGET.ACTION != null:
				if !action.TARGET.ACTION.is_joinable(): continue # cursed
				if !action.TARGET.ACTION.is_conversable(): continue
			return action
		else:
			# tile target
			if npc.LOCATION == action.TARGET:
				return action

			var is_reserved = Utility.is_location_reserved(action.TARGET)
			var is_travelable = $Map.is_travelable(action.TARGET)

			# find adjacent tile if possible
			if is_reserved or !is_travelable:
				if !action.can_do_off_tile(): continue
				var neighbors = get_neighbors(action.TARGET)
				var new_action_list = []
				for n in neighbors:
					var new_action = ACTIONS.new()
					new_action.ID = action.ID
					new_action.TARGET = action.TARGET
					new_action.LOCATION = n
					new_action.NEED = action.NEED
					new_action = npc.score_action(new_action)
					new_action_list.append(new_action)
				new_action_list.sort_custom(func(a,b): return b.SCORE < a.SCORE)
				for second_action in new_action_list:
					is_reserved = Utility.is_location_reserved(second_action.LOCATION)
					#is_travelable = second_action.TARGET.is_travelable() # get_neighbors always returns only travelable tiles
					if !is_reserved: return second_action
			else:
				return action
	push_error("action not found for", npc.NAME)

#endregion



#region pathfinding

#func step_towards_location(start, end):
func step_towards_location(end, start): #trying this out, pathfinding from target instead
	#pathfinding
	if start == end:
		push_error("Trying to pathfind to current location")
		return start # shouldn't happen but who knows

	var queue = [start]
	var visited = [start]
	var parent_dict = {}

	var current

	while len(queue) > 0:
		#var current = queue.pop_front()
		current = queue.pop_front()
		#print(current)
		if current == end:
			#print("found end")
			return parent_dict[end]
			#return get_next_step(parent_dict, start, end)
		for neighbor in get_neighbors(current):
			if Utility.is_location_reserved_by_occupant(neighbor): continue
			if neighbor in visited:
				continue
			visited.append(neighbor)
			queue.append(neighbor)
			parent_dict[neighbor] = current
	push_error("pathfind fail")

func get_neighbors(location):
	var neighbors = [
		[location[0], location[1]],
		# adjacent
		[location[0] + 1, location[1]],
		[location[0] - 1, location[1]],
		[location[0], location[1] + 1],
		[location[0], location[1] - 1],
		# diagonals
		[location[0] + 1, location[1] + 1],
		[location[0] + 1, location[1] - 1],
		[location[0] - 1, location[1] + 1],
		[location[0] - 1, location[1] - 1]
	]
	var valid_neighbors = []
	for n in neighbors:
		if n[0] < 0 or n[0] >= Constants.MAP_SIZE[0]:
			continue
		if n[1] < 0 or n[1] >= Constants.MAP_SIZE[1]:
			continue
		if !$Map.is_travelable(n): continue
		valid_neighbors.append(n)
		
	return valid_neighbors

func get_next_step(parent_dict, start, end):
	#print("parent_dict", str(parent_dict))
	var node = end
	while true:
		var parent = parent_dict[node] #not sure if i can use a list as a key in godot 
		if parent == start:
			return node
		node = parent

#endregion
	


#region menus
func open_npc_menu(npc):
	print("showing menu")
	$DefaultMenu.hide()
	var history = History.filter_by_npc(npc.ID)
	var history_list = History.display_history(history)
	$NpcMenu.initialize(npc, history_list)
	var dialogue_list = []
	history = History.filter_by_npc(npc)
	for h in history:
		if h["action"] == "converse":
			dialogue_list.append(h["arg"]["dialogue"])
	#var history_list = History.display_history(history)
	$TalkMenu.initialize(npc, dialogue_list)
	$NpcMenu.show()

func close_npc_menu():
	$TalkMenu.hide()
	$NpcMenu.hide()
	$DefaultMenu.show()


func open_talk_menu(npc):
	open_npc_menu(npc)
	$TalkMenu.show()

func close_talk_menu():
	$TalkMenu.hide()



#endregion


#region debug
		


#endregion
