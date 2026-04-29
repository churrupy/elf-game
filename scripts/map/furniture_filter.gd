class_name FURNITURE_FILTER extends RefCounted

var ENGINE

var furn_list:Array[Furniture]
var is_not_list:Array[Furniture] = []
var filtered_list:Array[Furniture]

var origin:Vector2 = Vector2.INF
var location:Vector2 = Vector2.INF
var distance:float = 1.5 # one tile away
var tags:Array[String] = []

var be_available:bool = false

func _init(engine) -> void:
	ENGINE = engine

func set_list(_furn_list:Array[Furniture]=[]) -> FURNITURE_FILTER:
	if _furn_list == []:
		furn_list = ENGINE.Map.FURNITURE
	else:
		furn_list = _furn_list
	return self

func in_range_of(_origin:Vector2, _distance:float) -> FURNITURE_FILTER:
	origin=_origin
	distance=_distance
	return self

func is_in_room() -> void:
	pass #placeholder

func has_tag(_tag:String) -> FURNITURE_FILTER:
	tags.append(_tag)
	return self

func is_available() -> FURNITURE_FILTER:
	# should this always be true?
	be_available = true
	return self

func at_location(loc:Vector2) -> FURNITURE_FILTER:
	location = loc
	return self


func run_filter() -> Array[Furniture]:
	for furn:Furniture in furn_list:
		if furn in is_not_list:continue

		if location != Vector2.INF:
			if furn.LOCATION != location:
				continue

		if origin != Vector2.INF:
			if origin.distance_to(furn.LOCATION) > distance:
				continue

		if len(tags) > 0:
			var matched:bool = true
			var f_tags:Array  = furn.DATA["tags"]
			for tag:String in tags:
				if tag not in f_tags: 
					matched = false
					break
			if !matched: continue

		if be_available:
			if ENGINE.NpcManager.is_reserved(furn.LOCATION): continue

		filtered_list.append(furn)

	return filtered_list
