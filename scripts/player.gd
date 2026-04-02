extends Node2D

class_name Player

var ID:String = "player"

var LOCATION: Vector2
var ACTION: IdleAction
var NEEDS: Dictionary
var COLOR: Color = Color(1,1,1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(delta:float) -> void:
	return
