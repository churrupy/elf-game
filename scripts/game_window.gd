class_name GAME_WINDOW extends Node

const TILE_SIZE:int = 64
var TILE_CENTER:Vector2 = Vector2(TILE_SIZE/2, TILE_SIZE/2)

var SCREEN_SIZE:Vector2

var LEFT_PANEL_SIZE:Vector2
var LEFT_PANEL_LOCATION:Vector2

var CENTER_PANEL_SIZE:Vector2
var CENTER_PANEL_LOCATION:Vector2

var RIGHT_PANEL_SIZE:Vector2
var RIGHT_PANEL_LOCATION:Vector2

var MAP_CENTER:Vector2

var NUM_X_TILES:int # how many times TILE_SIZE goes into SCREEN_SIZE
var NUM_Y_TILES:int # how many times TILE_SIZE goes into SCREEN_SIZE

var X_RANGE:Vector2
var Y_RANGE:Vector2

var ENGINE

var FOCUS_TARGET:String
var FOCUS_LOCATION:Vector2

var CAMERA:Camera = Camera.new()

var FULL_SCREEN:bool = false

func _init(engine) -> void:
	ENGINE = engine
	FOCUS_TARGET = "player"
	SCREEN_SIZE = DisplayServer.window_get_size()
	update_window()

func _process(_delta:float) -> void:
	var screen_check:Vector2 = ENGINE.get_window().size
	
	if int(screen_check[0]) != int(SCREEN_SIZE[0]) or int(screen_check[1]) != int(SCREEN_SIZE[1]):
		SCREEN_SIZE = screen_check
		update_window()
		update_map_center()
		ENGINE.update_window()


#region update
func update() -> void:
	update_map_center()
	

func update_map_center() -> void:
	var focus_npc
	if FOCUS_TARGET == "camera":
		focus_npc = CAMERA
	elif FOCUS_TARGET == "player":
		focus_npc = ENGINE.get_node("Player")
	else:
		focus_npc = ENGINE.NpcManager.get_npc(FOCUS_TARGET)
	FOCUS_LOCATION = focus_npc.LOCATION
	focus_npc.global_position = MAP_CENTER + Vector2(-10,20) # being the focus puts the focus target in a strange spot in relation to map grid

	X_RANGE = Vector2(FOCUS_LOCATION[0]-int(NUM_X_TILES/2), FOCUS_LOCATION[0]+int(NUM_X_TILES/2)+NUM_X_TILES%2)
	Y_RANGE = Vector2(FOCUS_LOCATION[1]-int(NUM_Y_TILES/2), FOCUS_LOCATION[1]+int(NUM_Y_TILES/2)+NUM_Y_TILES%2)

	
func update_window() -> void:

	LEFT_PANEL_SIZE = Vector2(SCREEN_SIZE[0]/4, SCREEN_SIZE[1])
	LEFT_PANEL_LOCATION = Vector2.ZERO

	CENTER_PANEL_SIZE = Vector2(SCREEN_SIZE[0]/2, SCREEN_SIZE[1]) # map
	CENTER_PANEL_LOCATION = Vector2(LEFT_PANEL_LOCATION[0] + LEFT_PANEL_SIZE[0], 0)

	RIGHT_PANEL_SIZE = Vector2(SCREEN_SIZE[0]/4, SCREEN_SIZE[1])
	RIGHT_PANEL_LOCATION = Vector2(CENTER_PANEL_LOCATION[0] + CENTER_PANEL_SIZE[0], 0)

	MAP_CENTER = Vector2(CENTER_PANEL_SIZE[0]/2 + CENTER_PANEL_LOCATION[0], CENTER_PANEL_SIZE[1]/2)

	NUM_X_TILES = int(CENTER_PANEL_SIZE[0] / TILE_SIZE) 
	NUM_Y_TILES = int(CENTER_PANEL_SIZE[1] / TILE_SIZE) 



#endregion update

func set_focus_target(new_target:String) -> void:
	FOCUS_TARGET = new_target
	if FOCUS_TARGET == "camera":
		CAMERA.LOCATION = ENGINE.get_node("Player").LOCATION

	ENGINE.update()

	


func get_global_index(loc:Vector2) -> Vector2:
	# converts map location to screen grid position
	# if either index is -1, then location is currently off-screen
	var x_index:int = range(int(X_RANGE[0]), int(X_RANGE[1])).find(int(loc[0]))
	var y_index:int = range(int(Y_RANGE[0]), int(Y_RANGE[1])).find(int(loc[1]))
	return Vector2(x_index, y_index)

func get_global_location(loc:Vector2) -> Vector2:
	var index:Vector2 = get_global_index(loc)
	return index * TILE_SIZE


func in_center_panel(loc:Vector2) -> bool:
	return int(loc[0]) in range(int(CENTER_PANEL_LOCATION[0]), int(CENTER_PANEL_LOCATION[0]) + int(CENTER_PANEL_SIZE[0]))
