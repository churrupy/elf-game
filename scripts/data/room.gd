class_name ROOM extends RefCounted

var ID:String
var TYPE:String
var DATA:Dictionary
var SUBROOMS:Array[ROOM]
var DOOR_LIST:Array[DOOR]

var LOCATION:Vector2
var SIZE:Vector2

var wall_dict:Dictionary = {
		"up": Vector2.UP,
		"down": Vector2.DOWN,
		"left": Vector2.LEFT,
		"right": Vector2.RIGHT
	}



func _init(type:String, loc:Vector2, size:Vector2) -> void:
	ID = type + str(Global.get_counter())
	DATA = Rooms.ROOM_TEMPLATES[type]
	TYPE = type
	LOCATION = loc
	SIZE = size

func is_generic() -> bool:
	return DATA["generic"]

func in_room(loc:Vector2) -> ROOM:
	# skips checking generic subrooms
	if is_in_room(loc):
		for sub:ROOM in SUBROOMS:
			var result_room:ROOM = sub.in_room(loc)
			if result_room != null:
				return result_room
		return self
	return null


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

func right_inside_door() -> TILE:
	var door:DOOR = DOOR_LIST.pick_random()
	return door

func right_outside_door() -> Vector2:
	var door:DOOR = DOOR_LIST.pick_random()
	if door == null:
		return Vector2.INF
	var wall:String = door.wall

	var target_direction:Vector2 = door.LOCATION + wall_dict[wall]
	return target_direction



func is_secured() -> bool:
	if len(DOOR_LIST) == 0: return false
	for door:DOOR in DOOR_LIST:
		if door.opened: return false

	return true

func get_locations() -> Array[Vector2]:
	var loc_list:Array[Vector2]
	var area:int = SIZE[0] * SIZE[1]
	var width:int = SIZE[0]
	for i in range(0, area):
		var x:int = i%width
		var y:int = i/width
		var loc:Vector2 = Vector2(x,y)
		loc += LOCATION
		loc_list.append(loc)
	return loc_list

func get_tags() -> Array[String]:
	var tag_list:Array = []
	var furniture_data:Dictionary = DATA["furniture"]
	for furn:String in furniture_data.keys():
		var furn_data:Dictionary = Constants.TILE_TEMPLATES[furn]
		tag_list += furn_data["tags"]
		
	var _tag_list:Array[String]
	_tag_list.assign(tag_list)
	return _tag_list

func get_tags_from_subrooms() -> Array[String]:
	var tag_list:Array[String] = get_tags()
	for subroom:ROOM in SUBROOMS:
		tag_list += subroom.get_tags_from_subrooms()
	return tag_list

func has_tag(tag:String) -> bool:
	var tag_list:Array[String] = get_tags()
	return tag in tag_list

func has_tag_in_subrooms(tag:String) -> bool:
	var tag_list:Array[String] = get_tags_from_subrooms()
	return tag in tag_list




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
