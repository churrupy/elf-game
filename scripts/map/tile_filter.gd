class_name TILE_FILTER extends RefCounted

var ENGINE

var tile_list:Array[TILE]
var is_not_list:Array[TILE] = []
var filtered_list:Array[TILE]

var origin:Vector2 = Vector2.INF
var location:Vector2 = Vector2.INF
var distance:float = 1.5
var tags:Array[String] = []

var target_room:ROOM

var be_available:bool = false

func _init(engine) -> void:
	ENGINE = engine

func set_list(_tile_list:Array[TILE] = []) -> TILE_FILTER:
	if _tile_list == []:
		tile_list = ENGINE.Map.TILES
	else:
		tile_list = _tile_list
	return self

func in_range_of(_origin:Vector2, _distance:float) -> TILE_FILTER:
	origin=_origin
	distance=_distance
	return self

func is_in_room(_room:ROOM) -> TILE_FILTER:
	target_room = _room
	return self

func has_tag(_tag:String) -> TILE_FILTER:
	tags.append(_tag)
	return self

func is_available() -> TILE_FILTER:
	be_available = true
	return self

func at_location(loc:Vector2) -> TILE_FILTER:
	location = loc
	return self

func run_filter() -> Array[TILE]:
	for tile:TILE in tile_list:
		if tile in is_not_list: continue

		if location != Vector2.INF:
			if tile.LOCATION != location:
				continue

		if origin != Vector2.INF:
			if origin.distance_to(tile.LOCATION) > distance:
				continue

		if len(tags) > 0:
			var matched:bool = true
			var t_tags:Array = tile.DATA["tags"]
			for tag:String in tags:
				if tag not in t_tags:
					matched = false
					break
			if !matched: continue

		if be_available:
			if ENGINE.NpcManager.is_reserved(tile.LOCATION): continue

		filtered_list.append(tile)

	return filtered_list
