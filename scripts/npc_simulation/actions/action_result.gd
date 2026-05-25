class_name ActionResult extends RefCounted

var STATUS: String
var NEW_ACTION: ACTION
var ACTION_STACK:Array[ACTION]
var CONTINUE: bool = false

func _init(status:String, new_action: ACTION=null) -> void:
	STATUS = status
	NEW_ACTION = new_action

# func _init(status:String="") -> void:
# 	STATUS = status

func set_action(_action:ACTION) -> ActionResult:
	NEW_ACTION = _action
	return self

func set_status(_status:String) -> ActionResult:
	STATUS = _status
	return self

func continuing() -> ActionResult:
	CONTINUE = true
	return self

func _to_string() -> String:
	var _str: String = "[STATUS] " + STATUS + ": " + str(NEW_ACTION)
	return _str
