extends Node
class_name ENGINE

#var X_RANGE
#var Y_RANGE
@export var npc_scene: PackedScene
var History = HISTORY_CLASS.new()



var ID_COUNTER = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set engine in children
	for child in get_children():
		if "ENGINE" in child:
			child.ENGINE = self


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

		#add_child(npc)


		var displayed_npc = npc_scene.instantiate()
		displayed_npc.initialize(npc)
		add_child(displayed_npc)
		displayed_npc.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.MAIN_FRAME_POSITION[0] + Constants.TILE_SIZE/2
		displayed_npc.global_position[1] = y_index * Constants.TILE_SIZE + Constants.TILE_SIZE/2
		displayed_npc.show()





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
	$DefaultMenu.tick()
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
	Global.NEARBY_NPCS = []
	var adjacent_locations = get_neighbors(Global.PLAYER_LOCATION)
	for l in adjacent_locations:
		Global.NEARBY_NPCS += Utility.get_npc_from_location(l)

func tick_npcs():
	for npc_id in Global.NPCS.keys():
		print("ticking ", npc_id)
		var npc: NPC = Global.NPCS[npc_id]
		if npc.ACTION == null:
			npc.ACTION = determine_action(npc)
		elif npc.ACTION.STATUS == "finish":
			History.add_entry(npc.ID, "finished", npc.LOCATION, {"action": npc.ACTION.ID})
			npc.ACTION = null
		else:
			npc.ACTION.tick()
		if npc.ACTION.COUNTDOWN < 0:
			npc.ACTION = null
	print("")


#endregion

#region npc actions


func get_all_npc_actions():
	var npc_actions = ["converse", "flirt"]
	var all_actions = []
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]
		for npc_a in npc_actions:
			var action_data = Constants.ACTION_TEMPLATES[npc_a]
			#var action_class_id= action_data["class"]
			#var action_class = Constants.CLASS_TEMPLATES[action_class_id]
			var new_action = SocialAction.new(self, npc_a)
			#var new_action = action_data["type"].new(self, npc_a)
			new_action.TARGET = npc
			new_action.LOCATION = npc.LOCATION
			all_actions.append(new_action)
	return all_actions




func get_npcs_in_range(location):
	# gets all npcs with the same target who are nearby
	var close_npcs = []
	var target_neighbors = get_neighbors(location)
	for n in target_neighbors:
		close_npcs += Utility.get_npc_from_location(n)
	return close_npcs
	


#endregion


#region npc ai

func determine_action(npc):
	var all_actions = $Map.get_all_actions_on_map()
	all_actions += get_all_npc_actions()
	#var all_actions = get_all_npc_actions()
	for action in all_actions:
		action.OWNER = npc
		action.score()

	all_actions.sort_custom(func(a,b): return b.SCORE < a.SCORE)
	for action in all_actions:
		if action.can_do_action():
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
		current = queue.pop_front()
		if current == end:
			return parent_dict[end]
		for neighbor in get_neighbors(current):
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
	var node = end
	while true:
		var parent = parent_dict[node] #not sure if i can use a list as a key in godot 
		if parent == start:
			return node
		node = parent

#endregion
	


#region menus
func open_npc_menu(npc):
	$DefaultMenu.hide()
	$NpcMenu.initialize(npc)
	var dialogue_list = []
	#var history_list = History.history_to_string(history)
	$TalkMenu.initialize(npc)
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
