class_name ActionResult extends RefCounted

var STATUS: String
var NEW_ACTION: ACTION
var ACTION_STACK:Array[ACTION]
var CONTINUE: bool = false

func _init(status:String, new_action: ACTION=null) -> void:
	STATUS = status
	NEW_ACTION = new_action

func continuing() -> ActionResult:
	CONTINUE = true
	return self

func _to_string() -> String:
	var _str: String = "[STATUS] " + STATUS + ": " + str(NEW_ACTION)
	return _str
