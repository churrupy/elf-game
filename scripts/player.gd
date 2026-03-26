extends Node2D

class_name Player

signal tick
signal move_without_tick_signal

var ID = "player"

var LOCATION
var ACTION
var NEEDS
var COLOR = [1,1,1]

# doubletap vars
const DOUBLETAP_DELAY = .25
var doubletap_time = DOUBLETAP_DELAY
var last_direction



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Global.MAP_CENTER
	LOCATION = [randi_range(0,Constants.MAP_SIZE[0]-1), randi_range(0, Constants.MAP_SIZE[1]-1)]


func _process(delta:float) -> void:
	return
