extends Node
class_name ENGINE

var ticks = 0
@export var npc_scene: PackedScene
@export var action_scene: PackedScene



var ID_COUNTER = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in Constants.NUM_NPCS:
		create_npc()
	_on_tick()



func create_npc():
	var npc = npc_scene.instantiate()
	var tile = $Map.random_tile()
	npc.LOCATION = tile.LOCATION
	$Map.occupy_tile(npc)
	npc.initialize(ID_COUNTER)
	ID_COUNTER += 1
	add_child(npc)
	Global.NPCS[npc.ID] = npc
	npc.get_node("NpcMenuButton").connect("pressed", Callable(self, "open_sprite_pressed_menu").bind(npc))

func open_sprite_pressed_menu(npc):
	# i don't need no signal bus!!!!
	$HUD.get_node("DefaultMenu").hide()
	$HUD.get_node("NpcListMenu").show()
	$HUD.get_node("NpcListMenu").open_npc_menu_via_sprite(npc)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("auto_tick"):
		_on_tick()
	
#region ticks

func auto_tick() -> void:
	_on_tick()


func _on_move_without_tick() -> void:
	$Map.tick()
	gather_npcs()
	update_current_npcs()


func _on_tick() -> void:
	print("")
	print("ticking...")
	Global.TICKS += 1
	print("Ticks: ", Global.TICKS)
	print("player location:", Global.PLAYER_LOCATION)
	update_current_npcs()
	get_current_npcs()
	$Map.tick()
	$HUD.tick()
	

#endregion

func update_current_npcs():
	Global.CURRENT_NPCS = []
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]
		print("")
		print("ticking", npc)
		npc.tick()
		if npc.ACTION == null:
			var chosen_action = determine_action(npc)
			chosen_action.set_countdown()
			npc.ACTION = chosen_action
		if (npc.ACTION.LOCATION == npc.LOCATION):
			npc.ACTION.STATUS = "filling"
			npc.ACTION.do(npc)
		else:
			$Map.free_tile(npc.LOCATION)
			var next_step = step_towards_location(npc.LOCATION, npc.ACTION.LOCATION)
			if next_step == null:
				push_error("pathfinding: no valid path found, teleporting ", npc, " to target location")
				print("teleporting...")
				print(npc.LOCATION, npc.ACTION.LOCATION)
				npc.LOCATION = npc.ACTION.LOCATION
				$Map.occupy_tile(npc)
			else:
				npc.LOCATION = next_step
				$Map.occupy_tile(npc)
		
		if npc.ACTION.STATUS == "finish":
			npc.ACTION = null
		#$Map.MAP[npc.LOCATION[0]][npc.LOCATION[1]].OCCUPANT = npc

func get_current_npcs():
	var adjacent_locations = get_neighbors(Global.PLAYER_LOCATION)
	for l in adjacent_locations:
		var tile = $Map.get_tile(l)
		if tile.OCCUPANT != null:
			Global.CURRENT_NPCS.append(tile.OCCUPANT)


func determine_action(npc):
	var all_actions = $Map.get_all_actions_on_map()
	all_actions += get_all_group_actions()
	for action in all_actions:
		action = npc.score_action(action)

	all_actions.sort_custom(func(a, b): return b.SCORE < a.SCORE)
	for action in all_actions:
		var tile = $Map.get_tile(action.TARGET.LOCATION)
		if npc.LOCATION == tile.LOCATION:
			return action
		if tile.is_reserved():
			# can do off-tile?
			if !action.can_do_off_tile():
				continue
			var neighbors = get_neighbors(action.TARGET.LOCATION)
			for n in neighbors:
				tile = $Map.get_tile(n)
				if !tile.is_reserved():
					tile.RESERVED = npc
					action.LOCATION = tile.LOCATION
					return action
		else:
			tile.RESERVED = npc
			return action
	push_error("action not found for", npc.NAME)

func get_all_group_actions():
	var all_actions = []
	for child in get_children():
		if child is not NPC: continue
		if child.ACTION == null: continue
		if not child.ACTION.is_joinable(): continue
		var new_action = ACTIONS.new()
		new_action.ID = child.ACTION.ID
		new_action.TARGET = child.ACTION.TARGET
		new_action.LOCATION = child.ACTION.LOCATION
		new_action.NEED = child.ACTION.NEED
		new_action.FOLLOWING = child
		all_actions.append(new_action)
	return all_actions

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
			var tile = $Map.get_tile(neighbor)
			if tile.is_occupied(): continue
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
		[location[0], location[1] - 1]
	]
	var valid_neighbors = []
	for n in neighbors:
		if n[0] < 0 or n[0] >= Constants.MAP_SIZE[0]:
			continue
		if n[1] < 0 or n[1] >= Constants.MAP_SIZE[1]:
			continue
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
	
func gather_npcs():
	Global.CURRENT_NPCS = []
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]
		if is_adjacent(Global.PLAYER_LOCATION, npc.LOCATION):
			Global.CURRENT_NPCS.append(npc_id)
		print (npc.LOCATION)
		if npc.LOCATION[0] in range($Map.X_RANGE[0], $Map.X_RANGE[1]):
			if npc.LOCATION[1] in range($Map.Y_RANGE[0], $Map.Y_RANGE[1]):
				var tile = $Map.MAP[npc.LOCATION[0]][npc.LOCATION[1]]
				if tile.visible:
					npc.global_position = tile.global_position + Vector2(Constants.TILE_SIZE/2, Constants.TILE_SIZE/2)
					npc.show()
					continue
		npc.hide()


func is_on_or_next_to(loc1, loc2):
	if loc1==loc2:
		return true
	if $Map.MAP[loc1[0]][loc1[1]].is_occupied():
		return is_adjacent(loc1, loc2)
	return false

func is_adjacent(loc1, loc2):
	var x_diff = abs(loc1[0] - loc2[0])
	if x_diff > 1:
		return false
	var y_diff = abs(loc1[1] - loc2[1])
	if y_diff > 1:
		return false
	return true
