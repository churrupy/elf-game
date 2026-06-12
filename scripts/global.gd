extends Node

var TICKS: int = 0

var FOCUS_TARGET: String
var FOCUS_LOCATION: Vector2

var ID_COUNTER: int = 0

func get_counter() -> int:
	ID_COUNTER += 1
	return ID_COUNTER


func prettify_vector(v:Vector2) -> String:
	return "(" + str(int(v[0])) + "," + str(int(v[1])) + ")"


var X_RANGE
var Y_RANGE
