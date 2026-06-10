extends Node

var GameWindow:GAME_WINDOW
var Map:MAP
#var History:Control
var History:HISTORY_CLASS = HISTORY_CLASS.new(self)

# managers
var NpcManager:NPC_MANAGER
var InventoryManager:INVENTORY_MANAGER = INVENTORY_MANAGER.new(self)
var GroupManager:GROUP_MANAGER = GROUP_MANAGER.new(self)


# menus
var MenuBones:MENU_BONES
var Journal:JOURNAL
var CraftMenu:CRAFT_MENU
var PlayerMenu:PLAYER_MENU



var UPDATABLES:Array
var FULL_SCREEN:bool = false

#region gamestate data
var MODE:String = "workshop"
var AUTORUN_TICKS:int = 00
var ROOM:String
var NUM_NPCS:int

#endregion gamestatedata


func _init() -> void:

	var mode_data:Dictionary = Modes.MODES[MODE]
	GameWindow = GAME_WINDOW.new(self)
	Map = MAP.new(self, mode_data["room"])

	#init managers
	NpcManager = NPC_MANAGER.new(self, mode_data["num_npcs"])

	#init menus
	MenuBones = MENU_BONES.new(self)
	Journal = JOURNAL.new(self, MenuBones)
	#CraftMenu = CRAFT_MENU.new(self, MenuBones)
	#PlayerMenu = PLAYER_MENU.new(self)


#region init
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# set engine in children
	add_child(Map)
	move_child(Map, 0)
	add_child(NpcManager)
	NpcManager.show()
	add_child(MenuBones)
	add_child(Journal)
	#add_child(CraftMenu)
	#add_child(PlayerMenu)
	for child in get_children():
		if "ENGINE" in child:
			child.ENGINE = self

	UPDATABLES = [
		GameWindow,
		Map,
		NpcManager,
		$HistoryMenu,
		$TalkMenu,
		MenuBones,
		Journal,
		# CraftMenu,
		$DefaultMenu,
		# PlayerMenu,
		
	]

	initialize_player()

	$TalkMenu.hide()


func initialize_player():
	print("initializing player")
	# creating inventory
	InventoryManager.create_inventory($Player)

	# putting player on map
	var loc_filter:LOCATION_FILTER = LOCATION_FILTER.new(self).set_list().is_passable()
	var passable_locations:Array[Vector2] = loc_filter.run_filter()
	$Player.LOCATION = passable_locations.pick_random()

	# giving initial entry to journal
	MenuBones.CURRENT_ENTRY = $Player
	MenuBones.init_presets() # because the journal is stupid
	# update_focus_target("player")

#endregion
#region process

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("esc"):
		quit()
	
	#print(Global.FOCUS_TARGET)

	while AUTORUN_TICKS >= 0:
		AUTORUN_TICKS -= 1
		tick()
		return

	GameWindow._process(0.0)
	
	# mouse control
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	$MousePositionLabel.text = prettify_vector(mouse_position)

	if GameWindow.in_center_panel(mouse_position):
	# if int(mouse_position[0]) in range(int(GameWindow.CENTER_PANEL_LOCATION[0]), int(GameWindow.CENTER_PANEL_LOCATION[0] + Constants.CENTER_PANEL_SIZE[0])):
	# if int(mouse_position[0]) in range(int(Constants.CENTER_PANEL_LOCATION[0]), int(Constants.CENTER_PANEL_LOCATION[0] + Constants.CENTER_PANEL_SIZE[0])):
		var location:Vector2 = Map.get_location_from_mouse(mouse_position)
		$MouseTileLabel.text = prettify_vector(location)
		if Map.is_in_line_of_sight($Player.LOCATION, location): 
			$MouseTileLabel.text += " **"

		var loc_items:Array = get_all_at_location(location)
		loc_items.sort_custom(func(a,_b): return a is NPC)
		var loc_names:Array[String]
		loc_names.assign(loc_items.map(func(a): return a.NAME))
		var loc_tag:String = ", ".join(loc_names)
		$PeekLabel.text = loc_tag
		# var loc_ids:Array[String]
		# loc_ids.assign(loc_items.map(func(a): return a.ID))

		# $DefaultMenu.open_menus(loc_ids)

		if Input.is_action_just_pressed("mouse_click") and len(loc_items) > 0:
			var top_item:Node = loc_items[0]
			# Journal.toggle_journal(top_item.ID)
			MenuBones.update_current_entry(top_item)
			# $DefaultMenu.hold_menus(loc_ids)

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

	if GameWindow.FOCUS_TARGET == "camera":
		print("moving camera")
		GameWindow.CAMERA.LOCATION += delta_direction
		update()
	else:
		var new_location: Vector2 = $Player.LOCATION + delta_direction
		if Map.is_passable(new_location, $Player.LOCATION):
			$Player.LOCATION = new_location
			tick()
		else:
			update()
	
	
#endregion process
#region ticks


func tick() -> void:
	
	print("")
	print("ticking...")
	
	Global.TICKS += 1
	print("Ticks: ", Global.TICKS)
	print("Focused on " + Global.FOCUS_TARGET + " at " + str(Global.FOCUS_LOCATION))
	NpcManager.tick()
	update()


#endregion


#region updates

func update() -> void:
	#print("updating map center")
	#update_map_center()

	print("updating main")
	
	for u in UPDATABLES:
		if "update" in u:
			u.update()

	update_player()

func update_window() -> void:
	for child in get_children():
		if "update_window" in child:
			child.update_window()

	update()


func update_player() -> void:
	if Global.FOCUS_TARGET != "player":
		var global_location:Vector2 = GameWindow.get_global_location($Player.LOCATION)
		if global_location[0] < 0 or global_location[1] < 0:
			$Player.global_position = Vector2(-100,-100) # put them off-screen
			return
		
		# orient to center panel
		global_location += Vector2(GameWindow.CENTER_PANEL_LOCATION[0], 0)
		# orient to center of tile
		global_location += GameWindow.TILE_CENTER
		$Player.position = global_location
		
		# var x_index: int = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(int($Player.LOCATION[0]))
		# if x_index < 0:
		# 	$Player.global_position = Vector2(-100,-100) # put them off-screen
		# 	return
		# var y_index: int = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(int($Player.LOCATION[1]))
		# if y_index < 0:
		# 	$Player.global_position = Vector2(-100,-100) # put them off-screen
		# 	return
		# $Player.global_position[0] = (x_index * Constants.TILE_SIZE) + GameWindow.CENTER_PANEL_LOCATION[0]
		# # $Player.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.CENTER_PANEL_LOCATION[0]
		# $Player.global_position[1] = y_index * Constants.TILE_SIZE
		# $Player.global_position = $Player.global_position + Vector2(Constants.TILE_SIZE/2, Constants.TILE_SIZE/2)
		


# func update_focus_target(new_target: String) -> void:
# 	print("UPDATING FOCUS")
# 	print("updating focus target:", new_target)
# 	Global.FOCUS_TARGET = new_target
# 	var target_object
# 	if new_target == "cam":
# 		target_object = CAMERA
# 		target_object.LOCATION = $Player.LOCATION
# 	elif new_target == "player":
# 		target_object = $Player
# 	else:
# 		target_object = Global.NPCS[new_target]
# 	target_object.global_position = GameWindow.MAP_CENTER + Vector2(-10,20)
# 	# target_object.global_position = Constants.MAP_CENTER + Vector2(-10,20)
# 	update()


# func update_map_center():
# 	var focus_npc
# 	if Global.FOCUS_TARGET == "cam":
# 		focus_npc = CAMERA
# 	elif Global.FOCUS_TARGET == "player":
# 		focus_npc = $Player
# 	else:
# 		focus_npc = Global.NPCS[Global.FOCUS_TARGET]
# 	Global.FOCUS_LOCATION = focus_npc.LOCATION
	# Global.X_RANGE = [Global.FOCUS_LOCATION[0] - Constants.NUM_X_TILES/2, Global.FOCUS_LOCATION[0] + (Constants.NUM_X_TILES/2 + 1)]
	# Global.Y_RANGE = [Global.FOCUS_LOCATION[1] - Constants.NUM_Y_TILES/2, Global.FOCUS_LOCATION[1] + (Constants.NUM_Y_TILES/2 + 1)]

	
#endregion updates

#region debug
func prettify_vector(v:Vector2) -> String:
	return "(" + str(int(v[0])) + "," + str(int(v[1])) + ")"


#endregion

# func get_screen_index(loc:Vector2) -> Vector2:
# 	var x_index: int = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(int(loc[0]))
# 	var y_index: int = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(int(loc[1]))
# 	return Vector2(x_index, y_index)

# func is_on_screen(object: Node) -> bool:
# 	var location: Vector2 = object.LOCATION
# 	var x_index: int = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(int(location[0]))
# 	if x_index < 0:
# 		return false
# 	var y_index: int = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(int(location[1]))
# 	if y_index < 0:
# 		return false
# 	return true



func activate_free_cam() -> void:
	if GameWindow.FOCUS_TARGET == "camera":
		GameWindow.set_focus_target("player")
		$FreeCamButton.text = "Free Cam"
	else:
		GameWindow.set_focus_target("camera")
		$FreeCamButton.text = "Stop Free Cam"
		
	# GameWindow.set_focus_target("camera")
	# print("focus target:", Global.FOCUS_TARGET)
	# if Global.FOCUS_TARGET != "cam":
	# 	update_focus_target("cam")
	# 	$FreeCamButton.text = "Stop Free Cam"
	# else:
	# 	update_focus_target("player")
	# 	$FreeCamButton.text = "Free Cam"

func toggle_history_menu() -> void:
	$HistoryMenu.toggle_menu()


func get_all_at_location(loc:Vector2) -> Array:
	var all_items:Array = []

	var npc_list:Array[NPC] = NPC_FILTER.new(self).set_list().set_location(loc).run_filter()
	all_items += npc_list

	var tile_list:Array[TILE] = TILE_FILTER.new(self).set_list().set_location(loc).not_empty().run_filter()
	all_items += tile_list
	

	return all_items


func toggle_full_screen() -> void:
	if FULL_SCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$FullScreenButton.text = "Make Full Screen"
		FULL_SCREEN = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$FullScreenButton.text = "Make Windowed"
		FULL_SCREEN = true
		print("WINDOW CHECK ", get_window().size)
		print("")
		print("processing full screen")
	GameWindow._process(0.0)


func quit() -> void:
	get_tree().quit()
