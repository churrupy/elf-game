extends Node2D

class_name Player

signal tick
signal move_without_tick_signal

# doubletap vars
const DOUBLETAP_DELAY = .25
var doubletap_time = DOUBLETAP_DELAY
var last_direction



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(Constants.MAIN_FRAME_SIZE[0]/2 + Constants.MAIN_FRAME_POSITION[0], Constants.MAIN_FRAME_SIZE[1]/2)
	#print("player position", position)
	Global.PLAYER_LOCATION = [randi_range(0,Constants.MAP_SIZE[0]-1), randi_range(0, Constants.MAP_SIZE[1]-1)]


func _process(delta:float) -> void:
	doubletap_time -= delta
	var delta_direction = [0,0]
	if Input.is_action_just_pressed("move_right"):
		last_direction = "right"
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
	#var old_location = [Global.PLAYER_LOCATION[0], Global.PLAYER_LOCATION[1]]
	var old_location = [Global.PLAYER_LOCATION[0] + Global.PLAYER_LOCATION[1]]
	var new_location = [Global.PLAYER_LOCATION[0] + delta_direction[0], Global.PLAYER_LOCATION[1] + delta_direction[1]]

	SignalBus.player_move_request.emit(new_location)
	return
	Global.PLAYER_LOCATION[0] += delta_direction[0]
	Global.PLAYER_LOCATION[0] = clamp(Global.PLAYER_LOCATION[0], 0, Constants.MAP_SIZE[0]-1)
	Global.PLAYER_LOCATION[1] += delta_direction[1]
	Global.PLAYER_LOCATION[1] = clamp(Global.PLAYER_LOCATION[1], 0, Constants.MAP_SIZE[1]-1)

	if Input.is_action_just_pressed("suppress_tick"):
		print("tick suppressed")
		move_without_tick_signal.emit()
	else:
	
		if old_location != Global.PLAYER_LOCATION and !Input.is_action_pressed("suppress_tick"):
			tick.emit()
