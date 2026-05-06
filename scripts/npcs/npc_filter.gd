class_name NPC_FILTER extends RefCounted

var ENGINE

var npc_list:Array[NPC]
var is_not_list:Array[NPC] = []

var origin:Vector2 = Vector2.INF 
var target:Vector2 = Vector2.INF
var location:Vector2 = Vector2.INF
var direction:Vector2 = Vector2.INF

var distance:int
var is_looking_at:bool = false
var be_available:bool = false
var target_room:ROOM

var filtered_list:Array[NPC]


func _init(engine) -> void:
	ENGINE = engine

func set_list(_npc_list:Array[NPC] = ENGINE.NpcManager.NPCS) -> NPC_FILTER:
	npc_list = _npc_list
	return self


func in_range_of(_origin:Vector2, _distance:int) -> NPC_FILTER:
	origin=_origin
	distance=_distance
	return self

func in_arc_of(_direction:Vector2) -> NPC_FILTER:
	# origin of arc is always origin of range
	direction = _direction
	return self


func looking_at(_target:Vector2=Vector2.INF) -> NPC_FILTER:
	is_looking_at = true
	if _target != Vector2.INF:
		target=_target
	return self

func is_on(_location:Vector2=Vector2.INF) -> NPC_FILTER:
	if _location != Vector2.INF:
		location = _location
	else:
		location = origin
	return self

func is_available() -> NPC_FILTER:
	be_available = true
	return self

func is_not(_is_not_list:Array[NPC]) -> NPC_FILTER:
	is_not_list = _is_not_list
	return self

func is_in_room(_room:ROOM) -> NPC_FILTER:
	target_room = _room
	return self


func run_filter() -> Array[NPC]:
	#print("FILTERING check")
	for npc:NPC in npc_list:
		#print(npc)
		#print(is_not_list)
		if npc in is_not_list: continue

		if location != Vector2.INF:
			if npc.LOCATION != location: continue

		if origin != Vector2.INF:
			if origin.distance_to(npc.LOCATION) > distance:
				continue
			
			if direction != Vector2.INF:
				var _direction = origin.direction_to(npc.LOCATION)
				if _direction.dot(direction) <= -0.5:
					continue
		
		if is_looking_at:
			var _target:Vector2 = origin
			if target != Vector2.INF:
				_target = target
			var direction = npc.LOCATION.direction_to(_target)
			if direction.dot(npc.DIRECTION) <= -0.5:
				continue
		
		if be_available:
			var current_action: ACTION = npc.STATE_STACK[-1]
			if !current_action.CHATTABLE:
				continue

		if target_room != null:
			var npc_room:ROOM = ENGINE.Map.get_room(npc.LOCATION)
			if npc_room != target_room: continue

		filtered_list.append(npc)
	#print(filtered_list)
	
	return filtered_list
