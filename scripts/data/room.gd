class_name ROOM extends RefCounted

var ID:String
var TYPE:String
var DATA:Dictionary
var SUBROOMS:Array[ROOM]
var DOOR_LIST:Array[DOOR]

var LOCATION:Vector2
var SIZE:Vector2


func _init(type:String, loc:Vector2, size:Vector2) -> void:
	ID = type + str(Global.get_counter())
	DATA = Rooms.ROOM_TEMPLATES_new[type]
	TYPE = type
	LOCATION = loc
	SIZE = size

func is_in_room(loc:Vector2) -> bool:
	# check doors first cause i made this too complicated
	for d:DOOR in DOOR_LIST:
		if d.LOCATION == loc: return true

	var top_left:Vector2
	var bottom_right:Vector2
	if "walls" in DATA:
		top_left = LOCATION + Vector2.ONE
		bottom_right = top_left + (SIZE - Vector2(2,2))
	else:
		top_left = LOCATION
		bottom_right = LOCATION + SIZE

	if int(loc[0]) not in range(int(top_left[0]), int(bottom_right[0]+1)):
		return false
	if int(loc[1]) not in range(int(top_left[1]), int(bottom_right[1]+1)):
		return false
	return true

func in_room(loc:Vector2) -> ROOM:
	if is_in_room(loc):
		for sub:ROOM in SUBROOMS:
			var result_room:ROOM = sub.in_room(loc)
			if result_room != null:
				return result_room
		return self
	return null

func is_secured() -> bool:
	for door:DOOR in DOOR_LIST:
		if door.opened: return false

	return true


func _to_string() -> String:
	return ID

func print_info() -> void:
	var display_list:Array[String] = [
		ID,
		"; Location: ",
		str(LOCATION),
		"; Size: ",
		str(SIZE)
	]
	print("".join(display_list))
