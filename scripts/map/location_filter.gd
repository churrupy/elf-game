class_name LOCATION_FILTER extends RefCounted

var ENGINE

var loc_list:Array[Vector2]
var is_not_list:Array[Vector2] = []
var filtered_list:Array[Vector2]

var origin:Vector2 = Vector2.INF
var direction:Vector2 = Vector2.INF

var distance:int

var be_available:bool = false
var be_passable:bool = false

func _init(engine) -> void:
	ENGINE = engine

func generate_list(_origin:Vector2, radius:int) -> LOCATION_FILTER:
	# radius is an int for calculation, NOT a distance for vector math
	# will create a rectangle
	origin = origin
	#distance = distance
	for i in range(int(origin[0])-radius, int(origin[0])+radius+1):
		if i < 0 or i >= Constants.MAP_SIZE[0]: continue
		for j in range(int(origin[1])-radius, int(origin[1])+radius+1):
			if j < 0 or j >= Constants.MAP_SIZE[1]: continue
			loc_list.append(Vector2(i,j))
	return self


func set_list(_loc_list:Array[Vector2] = []) -> LOCATION_FILTER:
	if len(loc_list) == 0:
		loc_list = ENGINE.Map.get_all_locations()
	else:
		loc_list = _loc_list
	return self

func in_range_of(_origin:Vector2, _distance:int) -> LOCATION_FILTER:
	origin=_origin
	distance=_distance
	return self

func in_arc_of(_direction:Vector2) -> LOCATION_FILTER:
	# origin of arc is always origin of range
	direction = _direction
	return self

func is_available() -> LOCATION_FILTER:
	# check reservation
	be_available = true
	return self

func is_passable() -> LOCATION_FILTER:
	be_passable = true
	return self




func run_filter() -> Array[Vector2]:
	for loc:Vector2 in loc_list:
		if loc in is_not_list: continue

		if origin != Vector2.INF:
			if origin.distance_to(loc) > distance:
				continue
			
			if direction != Vector2.INF:
				var _direction = origin.direction_to(loc)
				if _direction.dot(direction) <= -0.5:
					continue


		if be_available:
			# check reservation
			# holy shit i need a more memory-safe way to figure this out lol
			if ENGINE.NpcManager.is_reserved(loc): continue

		if be_passable:
			if !ENGINE.Map.is_passable(loc): continue
		
		filtered_list.append(loc)
	
	return filtered_list
