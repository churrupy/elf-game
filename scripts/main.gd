extends Node
#class_name ENGINE

#var X_RANGE
#var Y_RANGE
@export var npc_scene: PackedScene
var History = HISTORY_CLASS.new()



var ID_COUNTER = 0

#region init
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set engine in children
	for child in get_children():
		if "ENGINE" in child:
			child.ENGINE = self
	
	SignalBus.open_npc_menu.connect(open_npc_menu)
	SignalBus.close_npc_menu.connect(close_npc_menu)

	SignalBus.open_talk_menu.connect(open_talk_menu)
	SignalBus.close_talk_menu.connect(close_talk_menu)
	SignalBus.toggle_talk_menu.connect(toggle_talk_menu)

	
	Global.FOCUS_TARGET = "player"
	Global.FOCUS_LOCATION = $Player.LOCATION.duplicate()
	
	for i in Constants.NUM_NPCS:
		create_npc()
	$NpcMenu.hide()
	$TalkMenu.hide()
	tick()

func create_npc():
	var npc = NPC.new()
	var tile = $Map.random_empty_tile()
	npc.LOCATION = tile
	npc.initialize(ID_COUNTER)
	ID_COUNTER += 1
	#add_child(npc)
	Global.NPCS[npc.ID] = npc
	History.add_entry(npc.ID, "created", npc.LOCATION)

#endregion


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("auto_tick"):
		tick()
		return

	var delta_direction = [0,0]
	if Input.is_action_just_pressed("move_right"):
		print("right")
		delta_direction = [1,0]
	if Input.is_action_just_pressed("move_left"):
		print("left")
		delta_direction = [-1,0]
	if Input.is_action_just_pressed("move_up"):
		print("up")
		delta_direction = [0,-1]
	if Input.is_action_just_pressed("move_down"):
		print("down")
		delta_direction = [0,1]

	if delta_direction == [0,0]:
		return

	var new_location = [$Player.LOCATION[0] + delta_direction[0], $Player.LOCATION[1] + delta_direction[1]]
	if $Map.is_travelable(new_location):
		$Player.LOCATION = new_location
		$NpcMenu.unwatch_npc()
		tick()
	else:
		update_display()
	
	
#region ticks


func _on_move_without_tick() -> void:
	$Map.tick()
	get_current_npcs()
	#update_current_npcs()




func tick() -> void:
	
	update_map_center()
	print("")
	print("ticking...")
	Global.TICKS += 1
	print("Ticks: ", Global.TICKS)
	print("Focused on " + Global.FOCUS_TARGET + " at " + str(Global.FOCUS_LOCATION))
	tick_npcs()
	get_current_npcs()
	update_display()

func tick_npcs():
	for npc_id in Global.NPCS.keys():
		if npc_id == "player": continue
		print("ticking ", npc_id)
		var npc: NPC = Global.NPCS[npc_id]
		if npc.ACTION == null:
			npc.ACTION = determine_action(npc)
		elif npc.ACTION.STATUS == "finish":
			History.add_entry(npc.ID, "finished", npc.LOCATION, {"action": npc.ACTION.ID})
			npc.ACTION = null
		else:
			npc.ACTION.tick()
	print("")

#endregion


#region display

func update_display():
	print("updating map center")
	update_map_center()
	print("displaying npcs")
	display_npcs()
	print("displaying map")
	$Map.update()
	print("displaying defaultmenu")
	$DefaultMenu.update()
	if $NpcMenu.visible:
		print("displaying npcmenu")
		$NpcMenu.update()
	if $TalkMenu.visible:
		print("displaying talkmenu")
		$TalkMenu.update()


func update_focus_target(new_target):
	print("updating focus target")
	if new_target is not String:
		new_target = new_target.ID
	Global.FOCUS_TARGET = new_target
	var target_object
	if new_target == "player":
		target_object = $Player
	else:
		target_object = Global.NPCS[new_target]
	target_object.position = Global.MAP_CENTER
	update_display()


func update_map_center():
	var focus_npc
	if Global.FOCUS_TARGET == "player":
		focus_npc = $Player
	else:
		focus_npc = Global.NPCS[Global.FOCUS_TARGET]
	Global.FOCUS_LOCATION = focus_npc.LOCATION.duplicate()
	Global.X_RANGE = [Global.FOCUS_LOCATION[0] - 7, Global.FOCUS_LOCATION[0] + 8]
	Global.Y_RANGE = [Global.FOCUS_LOCATION[1] - 5, Global.FOCUS_LOCATION[1] + 6]



func display_npcs():
	for child in get_children():
		if child is NPC:
			remove_child(child)

	var npc_list = Global.NPCS.keys()
	if Global.FOCUS_TARGET != "player":
		npc_list.append("player")
	
	for npc_id in npc_list:
		
		var npc
		if npc_id == "player":
			npc = $Player
		else:
			npc = Global.NPCS[npc_id]

		if npc_id == Global.FOCUS_TARGET:
			add_child(npc)
			npc.global_position = Global.MAP_CENTER
			npc.show()
			continue

		var x_index = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(npc.LOCATION[0])
		if x_index < 0:
			continue
		var y_index = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(npc.LOCATION[1])
		if y_index < 0:
			continue

		if npc_id != "player":
			add_child(npc)

		
		npc.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.MAIN_FRAME_POSITION[0] + (Constants.TILE_SIZE/2)
		npc.global_position[1] = y_index * Constants.TILE_SIZE + Constants.TILE_SIZE/2
		#npc.show()


func get_current_npcs():
	Global.NEARBY_NPCS = []
	var adjacent_locations = get_neighbors(Global.FOCUS_LOCATION)
	for l in adjacent_locations:
		Global.NEARBY_NPCS += Utility.get_npc_from_location(l)
#endregion

func get_npc_list():
	var npc_list = []
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]
		npc_list.append(npc)
	return npc_list



#region npc actions


func get_all_npc_actions(checked_npc):
	var npc_actions = ["converse", "flirt", "seduce"]
	#var npc_actions = ["seduce"]
	var all_actions = []
	for npc_id in Global.NPCS.keys():
		if npc_id == checked_npc.ID: continue
		var npc = Global.NPCS[npc_id]
		for npc_a in npc_actions:
			var action_data = Constants.ACTION_TEMPLATES[npc_a]
			var action_class_id= action_data["class"]
			var action_class = Constants.CLASS_TEMPLATES[action_class_id]
			var new_action = action_class.new(self, npc_a)
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
	all_actions += get_all_npc_actions(npc)
	#var all_actions = get_all_npc_actions(npc)
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
		#[location[0], location[1]],
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

func get_closest_adjacent_tile(start_location, target_location):

	var neighbors = get_neighbors(target_location)
	if start_location in neighbors:
		return start_location
	var free_neighbors = Utility.filter_reserved_tiles(neighbors)

	if len(free_neighbors) == 0:
		print("no free adjacent tiles found")
		return null
	
	var smallest_distance = 100
	var closest_tile
	for t in free_neighbors:
		var distance = Utility.calc_distance(start_location, t)
		if distance < smallest_distance:
			smallest_distance = distance
			closest_tile = t
	return closest_tile



#endregion
	


#region menus
func open_npc_menu(npc):
	$DefaultMenu.hide()
	$NpcMenu.MENU_NPC = npc
	$NpcMenu.update()
	$NpcMenu.show()
	$TalkMenu.MENU_NPC = npc
	$TalkMenu.update()

func close_npc_menu():
	$TalkMenu.hide()
	$NpcMenu.hide()
	$DefaultMenu.show()


func toggle_talk_menu(npc):
	if $TalkMenu.visible:
		close_talk_menu()
	else:
		open_talk_menu(npc)


func open_talk_menu(npc):
	$NpcMenu.MENU_NPC = npc
	$NpcMenu.update()
	$NpcMenu.show()
	$TalkMenu.MENU_NPC = npc
	$TalkMenu.update()
	$TalkMenu.show()

func close_talk_menu():
	$TalkMenu.hide()



#endregion

#region tiles
func match_tile_to_closest_adjacent(tile_list, npc_location):
	# returns {target_tile: closest_neighbor}
	var filtered_tiles = {}
	for tile in tile_list:
		var tile_c = get_closest_adjacent_tile(npc_location, tile)
		if tile_c == null: continue
		filtered_tiles[tile] = tile_c
	return filtered_tiles


#endregion


#region debug
		


#endregion
