extends Node
#class_name ENGINE

#var X_RANGE
#var Y_RANGE
var Map:MAP = MAP.new(self, "club")
var History:HISTORY_CLASS = HISTORY_CLASS.new(self)
var NpcManager:NPC_MANAGER = NPC_MANAGER.new(self)





#region init
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set engine in children
	add_child(Map)
	move_child(Map, 0)
	add_child(NpcManager)
	NpcManager.show()
	#Map.hide()
	for child in get_children():
		if "ENGINE" in child:
			child.ENGINE = self
	
	SignalBus.open_npc_menu.connect(open_npc_menu)
	SignalBus.close_npc_menu.connect(close_npc_menu)

	SignalBus.open_talk_menu.connect(open_talk_menu)
	SignalBus.close_talk_menu.connect(close_talk_menu)
	SignalBus.toggle_talk_menu.connect(toggle_talk_menu)

	var passable_locations: Array[Vector2] = Map.filter_passable_locations()
	#var filtered_tiles: Array[TILE] = Utility.filter_reserved_tiles(passable_tiles)
	$Player.LOCATION = passable_locations.pick_random()
	update_focus_target("player")

	$NpcMenu.hide()
	$TalkMenu.hide()
	tick()

#endregion


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("auto_tick"):
		tick()
		return

	var delta_direction: Vector2 = Vector2.ZERO
	if Input.is_action_just_pressed("move_right"):
		print("right")
		delta_direction = Vector2.RIGHT
	if Input.is_action_just_pressed("move_left"):
		print("left")
		delta_direction = Vector2.LEFT
	if Input.is_action_just_pressed("move_up"):
		print("up")
		delta_direction = Vector2.UP
	if Input.is_action_just_pressed("move_down"):
		print("down")
		delta_direction = Vector2.DOWN

	if delta_direction == Vector2.ZERO:
		return

	var new_location: Vector2 = $Player.LOCATION + delta_direction
	#print("new location", new_location)
	#var new_location = [$Player.LOCATION[0] + delta_direction[0], $Player.LOCATION[1] + delta_direction[1]]
	if !Map.is_impassable(new_location):
		$Player.LOCATION = new_location
		$NpcMenu.unwatch_npc()
		tick()
	else:
		update_display()
	
	
#region ticks


func _on_move_without_tick() -> void:
	Map.tick()
	set_nearby_npcs()
	#update_nearby_npcs()




func tick() -> void:
	
	update_map_center()
	print("")
	print("ticking...")
	Global.TICKS += 1
	print("Ticks: ", Global.TICKS)
	print("Focused on " + Global.FOCUS_TARGET + " at " + str(Global.FOCUS_LOCATION))
	NpcManager.tick()
	set_nearby_npcs()
	update_display()


#endregion


#region display

func update_display():
	print("updating map center")
	update_map_center()
	print("displaying npcs")
	#display_npcs()
	NpcManager.update()
	print("displaying map")
	Map.update()
	print("displaying defaultmenu")
	$DefaultMenu.update()
	if $NpcMenu.visible:
		print("displaying npcmenu")
		$NpcMenu.update()
	if $TalkMenu.visible:
		print("displaying talkmenu")
		$TalkMenu.update()


func update_focus_target(new_target: String) -> void:
	print("updating focus target")
	Global.FOCUS_TARGET = new_target
	var target_object
	if new_target == "player":
		target_object = $Player
	else:
		target_object = Global.NPCS[new_target]
	target_object.position = Global.MAP_CENTER + Vector2(10,20)
	update_display()


func update_map_center():
	var focus_npc
	if Global.FOCUS_TARGET == "player":
		focus_npc = $Player
	else:
		focus_npc = Global.NPCS[Global.FOCUS_TARGET]
	Global.FOCUS_LOCATION = focus_npc.LOCATION
	Global.X_RANGE = [Global.FOCUS_LOCATION[0] - 9, Global.FOCUS_LOCATION[0] + 10]
	Global.Y_RANGE = [Global.FOCUS_LOCATION[1] - 5, Global.FOCUS_LOCATION[1] + 5]



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
		npc.show()


func set_nearby_npcs() -> void:
	Global.NEARBY_NPCS = []
	Global.NEARBY_NPCS = NpcManager.get_nearby_npcs($Player.LOCATION)
	#Global.NEARBY_NPCS = get_npcs_in_range($Player.LOCATION)
	
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
		var tile_c = Map.get_closest_adjacent_location(npc_location, tile)
		if tile_c == null: continue
		filtered_tiles[tile] = tile_c
	return filtered_tiles


#endregion


#region debug
		


#endregion
