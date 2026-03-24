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
	History.add_entry(npc.ID, "created")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("auto_tick"):
		_on_tick()
	
#region ticks

func process_player_move(location):
	if $Map.is_travelable(location):
		Global.PLAYER_LOCATION = location
	else:
		print("tile not accessible")
	History.add_entry("player", "moved to", location)
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
	#var npc_list = get_npc_list()
	#Utility.display_list_on_screen(npc_list, Constants.TILE_SIZE/2)
	#var tile_list = $Map.get_tile_list()
	#Utility.display_list_on_screen(tile_list)
	$Map.tick()
	var player_history = History.filter_by_npc("player")
	var player_history_list = History.display_history(player_history)
	$DefaultMenu.update_history_and_tick(player_history_list)
	#$DefaultMenu.tick()

	if $NpcMenu.visible:
		# re-initialize/update visible history
		open_npc_menu($NpcMenu.DISPLAYED_NPC)
	#$HUD.tick()
	

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
		var npc = Utility.get_npc_from_location(l)
		if npc != null:
			Global.CURRENT_NPCS.append(npc)


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
		if (npc.ACTION.LOCATION == npc.LOCATION):
			npc.ACTION.STATUS = "filling"
			npc.ACTION.do(npc)
			History.add_entry(npc.ID, npc.ACTION.ID)
		else:
			var next_step = step_towards_location(npc.LOCATION, npc.ACTION.LOCATION)
			if next_step == null:
				push_error("pathfinding: no valid path found, teleporting ", npc, " to target location")
				print("teleporting...")
				print(npc.LOCATION, npc.ACTION.LOCATION)
				npc.LOCATION = npc.ACTION.LOCATION
				History.add_entry(npc.ID, "teleported to", npc.ACTION.LOCATION)
				continue
			print(next_step)
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
			History.add_entry(npc.ID, "teleported to", npc.ACTION.LOCATION)
			npc.LOCATION = next_step
		
		if npc.ACTION.STATUS == "finish":
			History.add_entry(npc.ID, "finished", npc.ACTION.ID)
			npc.ACTION = null

		npc.decay_needs()
		npc.clamp_needs()
		#display_on_screen(npc, Constants.TILE_SIZE/2)



func get_all_group_actions():
	var all_actions = []
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]
		if npc.ACTION == null: continue
		if not npc.ACTION.is_joinable(): continue
		var new_action = ACTIONS.new()
		new_action.ID = npc.ACTION.ID
		new_action.TARGET = npc.ACTION.TARGET
		new_action.LOCATION = npc.ACTION.LOCATION
		new_action.NEED = npc.ACTION.NEED
		new_action.FOLLOWING = npc
		all_actions.append(new_action)
	return all_actions





func determine_action(npc):
	var all_actions = $Map.get_all_actions_on_map()
	all_actions += Utility.get_all_group_actions()
	for action in all_actions:
		action = npc.score_action(action)

	all_actions.sort_custom(func(a, b): return b.SCORE < a.SCORE)
	for action in all_actions:
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
	$NpcMenu.show()

func close_npc_menu():
	$NpcMenu.hide()
	$DefaultMenu.show()


func open_talk_menu(npc):
	open_npc_menu(npc)
	$TalkMenu.initialize(npc)
	$TalkMenu.show()

func close_talk_menu():
	$TalkMenu.hide()



#endregion


#region debug
		


#endregion
