extends TextureRect

class_name Tile

var TYPE
var LOCATION
var RESERVED
var OCCUPANT



func _ready() -> void:
	pass

func initialize():
	$TypeInitialLabel.text = TYPE.substr(0,6)
	$LocationLabel.text = str(int(LOCATION[0])) + "," + str(int(LOCATION[1]))
	var tile_data = Constants.TILE_TEMPLATES[TYPE]
	texture = load("res://models/" + tile_data["png"])
	

func _process(delta: float) -> void:
	pass

func is_empty():
	# no occupant
	if OCCUPANT != null:
		return false
	return true

func is_reservable():
	if RESERVED != null:
		return false
	return true

func is_travelable():
	var tile_data = Constants.TILE_TEMPLATES[TYPE]
	if tile_data["impassable"]:
		return false
	return true

func _to_string():
	var _str = TYPE + " at " + str(LOCATION)
	if OCCUPANT != null:
		_str += ", occupied by " + OCCUPANT.NAME
	return _str
