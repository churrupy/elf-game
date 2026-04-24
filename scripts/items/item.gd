class_name ITEM extends Node2D

var ID: String
var TYPE: String
var NAME: String
var TAGS: Array[String]
var DATA: Dictionary

func _init(type:String) -> void:
	ID = type + str(Global.get_counter())
	TYPE = type
	NAME = type
	DATA = Constants.ITEM_TEMPLATES[TYPE]
	TAGS.assign(DATA["tags"])


func _to_string() -> String:
	return NAME
