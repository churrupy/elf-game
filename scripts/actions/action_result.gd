class_name ActionResult extends RefCounted

var STATUS: String
var NEW_ACTION: ACTION

func _init(status:String, new_action: ACTION=null) -> void:
	STATUS = status
	NEW_ACTION = new_action

func _to_string() -> String:
	var _str: String = "[STATUS] " + str(NEW_ACTION) + ": " + STATUS
	return _str
