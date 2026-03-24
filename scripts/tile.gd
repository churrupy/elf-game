extends TextureRect

class_name Tile

var TYPE
var LOCATION
var RESERVED
var OCCUPANT



func _ready() -> void:
	pass

func initialize(type, location):
	$TypeInitialLabel.text = type.substr(0,6)
	$LocationLabel.text = str(int(location[0])) + "," + str(int(location[1]))
	var tile_data = Constants.TILE_TEMPLATES[type]
	texture = load("res://models/" + tile_data["png"])
	

func _process(delta: float) -> void:
	pass
