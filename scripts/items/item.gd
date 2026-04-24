class_name ITEM extends Node2D

var ID: String
var TYPE: String

func _init(type:String) -> void:
    ID = type + str(Global.get_counter())
    TYPE = type