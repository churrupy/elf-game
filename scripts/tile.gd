extends TextureRect

class_name Tile

var TYPE
var LOCATION
var OCCUPANT
var RESERVED 



func _ready() -> void:
	pass

func initialize():
	$TypeInitialLabel.text = TYPE.substr(0,6)
	$LocationLabel.text = str(int(LOCATION[0])) + "," + str(int(LOCATION[1]))
	#$LocationLabel.text = str([int(LOCATION[0]), int(LOCATION[1])])

func _process(delta: float) -> void:
	if OCCUPANT != null and OCCUPANT is not String:
		OCCUPANT.global_position = global_position + Vector2(30,30)
		OCCUPANT.visible = visible

func is_reserved():
	if RESERVED != null:
		return true
	if OCCUPANT != null:
		return true
	return false

func is_occupied():
	if OCCUPANT != null: return true
	var tile_data = Constants.TILE_TEMPLATES[TYPE]
	if tile_data["impassable"]: return true
	return false
	
	
func _to_string():
	var _str = TYPE + " at " + str(LOCATION)
	return _str


func _on_hover() -> void:
	if OCCUPANT != null:
		$OccupantLabel.text = OCCUPANT.NAME
	

func _on_hover_off():
	$OccupantLabel.text = ""
