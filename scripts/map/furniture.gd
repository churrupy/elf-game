class_name Furniture extends TextureRect

var ID: String
var NAME: String
var LOCATION: Vector2
var DATA: Dictionary

func _init(keyword:String, loc:Vector2) -> void:
	ID = keyword + str(Global.get_counter())
	NAME = keyword
	LOCATION = loc
	DATA = Constants.FURNITURE[keyword]
	texture = load("res://models/" + DATA["sprite"])

	
