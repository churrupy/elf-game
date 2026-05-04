class_name ROOM extends RefCounted

var TYPE:String
var DATA:Dictionary
var SUBROOMS:Array[ROOM]

var LOCATION:Vector2
var SIZE:Vector2


func _init(type:String, loc:Vector2, size:Vector2) -> void:
	DATA = Rooms.ROOM_TEMPLATES_new[type]
	TYPE = type
	LOCATION = loc
	SIZE = size

func is_in_room(loc:Vector2) -> bool:
	var local_loc: Vector2 = LOCATION + SIZE
	if int(loc[0]) not in range(int(LOCATION[0]), int(local_loc[0]+1)):
		return false
	if int(loc[1]) not in range(int(LOCATION[1]), int(local_loc[1]+1)):
		return false
	return true


func in_room(loc:Vector2) -> ROOM:
	if is_in_room(loc):
		for sub:ROOM in SUBROOMS:
			var result_room:ROOM = sub.in_room(loc)
			if result_room != null:
				print("returning", result_room)
				return result_room
		return self
	return null



func _to_string() -> String:
	return TYPE
