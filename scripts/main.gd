extends Node

var GameWindow:GAME_WINDOW
var Map:MAP
#var History:Control
var History:HISTORY_CLASS = HISTORY_CLASS.new(self)

# managers
var NpcManager:NPC_MANAGER
var InventoryManager:INVENTORY_MANAGER = INVENTORY_MANAGER.new(self)
var GroupManager:GROUP_MANAGER = GROUP_MANAGER.new(self)
var RelationshipManager:RELATIONSHIP_MANAGER = RELATIONSHIP_MANAGER.new(self)


# menus
var MenuBones:MENU_BONES



var UPDATABLES:Array 

#region gamestate data
var MODE:String = "club"
var AUTORUN_TICKS:int = 00
var NUM_NPCS:int
var FULL_SCREEN:bool = false

#endregion gamestatedata


func _init() -> void:
	# children here need other children initialized first before they can initialize properly
	var mode_data:Dictionary = Modes.MODES[MODE]
	GameWindow = GAME_WINDOW.new(self)
	Map = MAP.new(self, mode_data["room"])

	#init managers
	NpcManager = NPC_MANAGER.new(self, mode_data["num_npcs"])

	#init menus
	MenuBones = MENU_BONES.new(self)


#region init
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# set engine in children
	add_child(Map)
	move_child(Map, 0) # controls draw order
	add_child(NpcManager)
	add_child(MenuBones)

	# this is just a check, they should already be initialized with the engine anyways
	for child in get_children():
		if "ENGINE" in child:
			child.ENGINE = self

	UPDATABLES = [
		GameWindow,
		Map,
		NpcManager,
		$HistoryMenu,
		MenuBones,
		$DefaultMenu,
		
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
	MenuBones.init_presets() # because the journal is stupid

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
	$MousePositionLabel.text = Global.prettify_vector(mouse_position)

	if GameWindow.in_center_panel(mouse_position):
		var location:Vector2 = Map.get_location_from_mouse(mouse_position)
		$MouseTileLabel.text = Global.prettify_vector(location)
		if Map.is_in_line_of_sight($Player.LOCATION, location): 
			$MouseTileLabel.text += " **"

		var loc_items:Array = get_all_at_location(location)
		loc_items.sort_custom(func(a,_b): return a is NPC)
		var loc_names:Array[String]
		loc_names.assign(loc_items.map(func(a): return a.NAME))
		var loc_tag:String = ", ".join(loc_names)
		$PeekLabel.text = loc_tag

		if Input.is_action_just_pressed("mouse_click") and len(loc_items) > 0:
			var top_item:Node = loc_items[0]
			MenuBones.update_current_entry(top_item)

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
	# processes game state changes
	print("")
	print("ticking...")
	
	Global.TICKS += 1
	print("Ticks: ", Global.TICKS)
	print("Focused on " + GameWindow.FOCUS_TARGET + " at " + str(GameWindow.FOCUS_LOCATION))
	NpcManager.tick()
	update()


#endregion


#region updates

func update() -> void:
	# processes display changes based on changing game state
	print("updating main")
	for u in UPDATABLES:
		if "update" in u:
			u.update()

	update_player()

func update_window() -> void:
	# updates window/gui
	for child in get_children():
		if "update_window" in child:
			child.update_window()

	update()



func update_player() -> void:
	if GameWindow.FOCUS_TARGET != "player":
		var global_location:Vector2 = GameWindow.get_global_location($Player.LOCATION)
		if global_location[0] < 0 or global_location[1] < 0:
			$Player.global_position = Vector2(-100,-100) # put them off-screen
			return
		
		# orient to center panel
		global_location += Vector2(GameWindow.CENTER_PANEL_LOCATION[0], 0)
		# orient to center of tile
		global_location += GameWindow.TILE_CENTER
		$Player.position = global_location
		


	
#endregion updates



func activate_free_cam() -> void:
	if GameWindow.FOCUS_TARGET == "camera":
		GameWindow.set_focus_target("player")
		$FreeCamButton.text = "Free Cam"
	else:
		GameWindow.set_focus_target("camera")
		$FreeCamButton.text = "Stop Free Cam"
		
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
