extends TextureRect

class_name TILE

var TYPE: String
var LOCATION: Vector2
var INVENTORY: Array



func _init(type: String, location: Vector2) -> void:
	TYPE = type
	LOCATION = location
	var initial_label: Label = Label.new()
	var _str: String = TYPE.substr(0,6) + " " + str(int(LOCATION[0])) + "," + str(int(LOCATION[1]))
	initial_label.text = str(int(LOCATION[0])) + "," + str(int(LOCATION[1]))
	initial_label.position += Vector2(5,0)
	add_child(initial_label)
	#$TypeInitialLabel.text = TYPE.substr(0,6)
	#$LocationLabel.text = str(int(LOCATION[0])) + "," + str(int(LOCATION[1]))
	var tile_data: Dictionary = Constants.TILE_TEMPLATES[TYPE]
	texture = load("res://models/" + tile_data["png"])

func initialize() -> void:
	var tile_data: Dictionary = Constants.TILE_TEMPLATES[TYPE]
	texture = load("res://models/" + tile_data["png"])


func _to_string():
	return "Tile: " + str(LOCATION)

func _process(delta: float) -> void:
	pass



func initialize_old(type, location):
	$TypeInitialLabel.text = type.substr(0,6)
	$LocationLabel.text = str(int(location[0])) + "," + str(int(location[1]))
	var tile_data = Constants.TILE_TEMPLATES[type]
	texture = load("res://models/" + tile_data["png"])
	
