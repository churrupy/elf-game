class_name ROOM_FILTER extends RefCounted

var ENGINE

var room_list:Array[ROOM]
var is_not_list:Array[ROOM] = []
var filtered_list:Array[ROOM]

var tags:Array[String] = []

var use_subrooms:bool = false
var unlocked:bool = true

func _init(engine) -> void:
	ENGINE = engine

func set_list(_room_list:Array[ROOM] = ENGINE.Map.ROOM_LIST) -> ROOM_FILTER:
	room_list = _room_list
	return self

func has_tag(_tag:String) -> ROOM_FILTER:
	tags.append(_tag)
	return self

func include_subrooms() -> ROOM_FILTER:
	use_subrooms = true
	return self

func include_locked() -> ROOM_FILTER:
	unlocked = false
	return self


func run_filter() -> Array[ROOM]:
	for room:ROOM in room_list:

		if room.is_secured(): continue

		if len(tags) > 0:
			var matched:bool = true
			var r_tags:Array[String]
			if use_subrooms:
				r_tags = room.get_tags_from_subrooms()
			else:
				r_tags = room.get_tags()
			
			for tag:String in tags:
				if tag not in r_tags:
					matched = false
					break
			if !matched: continue


		filtered_list.append(room)
	return filtered_list
