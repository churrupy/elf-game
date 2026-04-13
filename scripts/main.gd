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
	#print($DefaultMenu.get_parent())
	add_child(Map)
	move_child(Map, 0)
	add_child(NpcManager)
	#move_child($DefaultMenu, 50)
	NpcManager.show()
	#Map.hide()
	for child in get_children():
		if "ENGINE" in child:
			child.ENGINE = self
	
	#SignalBus.open_npc_menu.connect(open_npc_menu)
	#SignalBus.keep_open_npc_menu.connect(keep_open_npc_menu)
	#SignalBus.close_npc_menu.connect(close_npc_menu)
	#SignalBus.try_close_npc_menu.connect(try_close_npc_menu)

	SignalBus.open_talk_menu.connect(open_talk_menu)
	SignalBus.close_talk_menu.connect(close_talk_menu)
	SignalBus.toggle_talk_menu.connect(toggle_talk_menu)

	SignalBus.open_journal.connect(open_journal)
	SignalBus.close_journal.connect(close_journal)
	SignalBus.update_journal.connect(update_journal)

	var passable_locations: Array[Vector2] = Map.filter_passable_locations()
	#var filtered_tiles: Array[TILE] = Utility.filter_reserved_tiles(passable_tiles)
	$Player.LOCATION = passable_locations.pick_random()
	update_focus_target("player")

	$TalkMenu.hide()
	tick()

#endregion


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	# mouse control
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	$MousePositionLabel.text = prettify_vector(mouse_position)

	
	if int(mouse_position[0]) in range(int(Constants.CENTER_PANEL_LOCATION[0]), int(Constants.CENTER_PANEL_LOCATION[0] + Constants.CENTER_PANEL_SIZE[0])):
		#print("over map")
		var location:Vector2 = Map.get_location_from_mouse(mouse_position)
		$MouseTileLabel.text = prettify_vector(location)
		if Map.is_in_line_of_sight($Player.LOCATION, location): 
			$MouseTileLabel.text += " **"

		var new_npcs: Array[String] = NpcManager.get_npc_from_location(location)
		$DefaultMenu.open_npc_menus(new_npcs)

		if Input.is_action_just_pressed("mouse_click"):
			$DefaultMenu.hold_temp_menus()
		

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
		#$NpcMenu.unwatch_npc()
		tick()
	else:
		update()
	
	
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
	update()


#endregion


#region display

func update():
	print("updating map center")
	update_map_center()
	print("displaying npcs")
	NpcManager.update()
	print("displaying map")
	Map.update()
	print("displaying defaultmenu")
	$DefaultMenu.update()
	if $TalkMenu.visible:
		print("displaying talkmenu")
		$TalkMenu.update()
	if $Journal.visible:
		$Journal.update()


func update_focus_target(new_target: String) -> void:
	print("updating focus target")
	Global.FOCUS_TARGET = new_target
	var target_object
	if new_target == "player":
		target_object = $Player
	else:
		target_object = Global.NPCS[new_target]
	target_object.global_position = Constants.MAP_CENTER + Vector2(-10,20)
	update()


func update_map_center():
	var focus_npc
	if Global.FOCUS_TARGET == "player":
		focus_npc = $Player
	else:
		focus_npc = Global.NPCS[Global.FOCUS_TARGET]
	Global.FOCUS_LOCATION = focus_npc.LOCATION
	Global.X_RANGE = [Global.FOCUS_LOCATION[0] - Constants.NUM_X_TILES/2, Global.FOCUS_LOCATION[0] + (Constants.NUM_X_TILES/2 + 1)]
	Global.Y_RANGE = [Global.FOCUS_LOCATION[1] - Constants.NUM_Y_TILES/2, Global.FOCUS_LOCATION[1] + (Constants.NUM_Y_TILES/2 + 1)]


func set_nearby_npcs() -> void:
	Global.NEARBY_NPCS = []
	Global.NEARBY_NPCS = NpcManager.get_nearby_npcs($Player.LOCATION)
	
#endregion





# #region menus
# func open_npc_menu(npc) -> void:
# 	#$DefaultMenu.hide()
# 	$NpcMenu.MENU_NPC = npc
# 	$NpcMenu.update()
# 	$NpcMenu.show()
# 	$TalkMenu.MENU_NPC = npc
# 	$TalkMenu.update()

# func keep_open_npc_menu() -> void:
# 	$NpcMenu.KEEP_OPEN = true


# func close_npc_menu(npc_id):
# 	$TalkMenu.hide()
# 	$NpcMenu.KEEP_OPEN = false
# 	$NpcMenu.hide()
# 	#$DefaultMenu.show()


func toggle_talk_menu(npc):
	if $TalkMenu.visible:
		close_talk_menu()
	else:
		open_talk_menu(npc)


func open_talk_menu(npc):
	$TalkMenu.MENU_NPC = npc
	$TalkMenu.update()
	$TalkMenu.show()

func close_talk_menu():
	$TalkMenu.hide()

func open_journal():
	$Journal.show()

func close_journal():
	$Journal.hide()

func update_journal(topic):
	$Journal.update_topic(topic)
	$Journal.show()



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
func prettify_vector(v:Vector2) -> String:
	return "(" + str(int(v[0])) + "," + str(int(v[1])) + ")"


#endregion
