extends Node
#class_name ENGINE

#var X_RANGE
#var Y_RANGE
var Map:MAP = MAP.new(self, "club")
#var History:Control
var History:HISTORY_CLASS = HISTORY_CLASS.new(self)
var NpcManager:NPC_MANAGER = NPC_MANAGER.new(self)
var CAMERA: Camera = Camera.new()





#region init
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set engine in children
	add_child(Map)
	move_child(Map, 0)
	add_child(NpcManager)
	NpcManager.show()
	for child in get_children():
		if "ENGINE" in child:
			child.ENGINE = self
	

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

	if Global.FOCUS_TARGET == "cam":
		CAMERA.LOCATION += delta_direction
		update()
	else:
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


func tick() -> void:
	update_map_center()
	print("")
	print("ticking...")
	Global.TICKS += 1
	print("Ticks: ", Global.TICKS)
	print("Focused on " + Global.FOCUS_TARGET + " at " + str(Global.FOCUS_LOCATION))
	NpcManager.tick()
	update()


#endregion


#region display

func update():
	print("updating map center")
	update_map_center()
	print("displaying map")
	Map.update()
	print("displaying npcs")
	NpcManager.update()
	update_player()
	$HistoryMenu.update()
	$TalkMenu.update()
	$Journal.update()
	
	print("displaying defaultmenu")
	$DefaultMenu.update()

	# if $TalkMenu.visible:
	# 	$TalkMenu.update()
	# if $Journal.visible:
	# 	$Journal.update()

func update_player() -> void:
	if Global.FOCUS_TARGET != "player":
		var x_index: int = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(int($Player.LOCATION[0]))
		if x_index < 0:
			$Player.global_position = Vector2(-100,-100) # put them off-screen
			return
		var y_index: int = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(int($Player.LOCATION[1]))
		if y_index < 0:
			$Player.global_position = Vector2(-100,-100) # put them off-screen
			return
		$Player.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.CENTER_PANEL_LOCATION[0]
		$Player.global_position[1] = y_index * Constants.TILE_SIZE
		$Player.global_position = $Player.global_position + Vector2(Constants.TILE_SIZE/2, Constants.TILE_SIZE/2)
		


func update_focus_target(new_target: String) -> void:
	print("updating focus target")
	Global.FOCUS_TARGET = new_target
	var target_object
	if new_target == "cam":
		target_object = CAMERA
		target_object.LOCATION = $Player.LOCATION
	elif new_target == "player":
		target_object = $Player
	else:
		target_object = Global.NPCS[new_target]
	target_object.global_position = Constants.MAP_CENTER + Vector2(-10,20)
	update()


func update_map_center():
	var focus_npc
	if Global.FOCUS_TARGET == "cam":
		focus_npc = CAMERA
	elif Global.FOCUS_TARGET == "player":
		focus_npc = $Player
	else:
		focus_npc = Global.NPCS[Global.FOCUS_TARGET]
	Global.FOCUS_LOCATION = focus_npc.LOCATION
	Global.X_RANGE = [Global.FOCUS_LOCATION[0] - Constants.NUM_X_TILES/2, Global.FOCUS_LOCATION[0] + (Constants.NUM_X_TILES/2 + 1)]
	Global.Y_RANGE = [Global.FOCUS_LOCATION[1] - Constants.NUM_Y_TILES/2, Global.FOCUS_LOCATION[1] + (Constants.NUM_Y_TILES/2 + 1)]

	

#region debug
func prettify_vector(v:Vector2) -> String:
	return "(" + str(int(v[0])) + "," + str(int(v[1])) + ")"


#endregion


func activate_free_cam() -> void:
	if Global.FOCUS_TARGET != "cam":
		update_focus_target("cam")
		$FreeCamButton.text = "Stop Free Cam"
	else:
		update_focus_target("player")
		$FreeCamButton.text = "Free Cam"

func toggle_history_menu() -> void:
	$HistoryMenu.toggle_menu()
