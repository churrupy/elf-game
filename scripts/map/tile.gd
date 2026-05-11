class_name TILE extends TextureRect

var ID: String
var NAME: String
var TYPE: String
var LOCATION: Vector2
var DATA:Dictionary


func _init(loc:Vector2, type:String="empty") -> void:
	ID = "tile" + str(Global.get_counter())
	TYPE = type
	NAME = "tile:" + str(loc)
	LOCATION = loc
	update_type(type)
	add_loc_label()
	# DATA = Constants.TILE_TEMPLATES[TYPE]
	# texture = load("res://models/" + DATA["sprite"])


func add_loc_label() -> void:
	var initial_label:Label = Label.new()
	initial_label.text = str(int(LOCATION[0])) + "," + str(int(LOCATION[1]))
	initial_label.position += Vector2(5,0)
	add_child(initial_label)


func update_type(new_type:String="empty") -> void:
	TYPE = new_type
	DATA = Constants.TILE_TEMPLATES[new_type]
	texture = load("res://models/" + DATA["sprite"])


# func _init_old(type: String, location: Vector2) -> void:
# 	ID = "tile" + str(Global.get_counter())
# 	TYPE = type
# 	NAME = "tile:" + str(location)
# 	LOCATION = location
# 	var initial_label: Label = Label.new()
# 	var _str: String = TYPE.substr(0,6) + " " + str(int(LOCATION[0])) + "," + str(int(LOCATION[1]))
# 	initial_label.text = str(int(LOCATION[0])) + "," + str(int(LOCATION[1]))
# 	initial_label.position += Vector2(5,0)
# 	add_child(initial_label)
# 	#$TypeInitialLabel.text = TYPE.substr(0,6)
# 	#$LocationLabel.text = str(int(LOCATION[0])) + "," + str(int(LOCATION[1]))
# 	var tile_data: Dictionary = Constants.TILE_TEMPLATES[TYPE]
# 	texture = load("res://models/" + tile_data["png"])


func _to_string():
	return "Tile: " + TYPE + " at " + str(LOCATION)
