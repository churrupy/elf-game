class_name EVENT_new extends RefCounted

var EVENT_ACTION:ACTION
var START_TICK:int
var END_TICK:int
var LOCATION:Vector2
var EVENT_ROOM:ROOM

func _init(_action:ACTION) -> void:
	EVENT_ACTION = _action
	START_TICK = Global.TICKS
	END_TICK = Global.TICKS
	LOCATION = _action.OWNER.LOCATION
	EVENT_ROOM = _action.get_room()


func _to_string() -> String:
	print(EVENT_ACTION.ID)
	var str_list:Array[String]
	if START_TICK == END_TICK:
		str_list = [
			"[T]:",
			str(START_TICK)
		]
	else:

		str_list = [
			"[T]:",
			str(START_TICK),
			"->",
			str(END_TICK)
		]
	
	var str_list2:Array[String] = [
		str(EVENT_ACTION),
		"at",
		str(EVENT_ROOM)
	]

	str_list += str_list2

	return " ".join(str_list)
