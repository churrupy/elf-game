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

var target_action_id:String = ""


func _init(engine) -> void:
	ENGINE = engine

func set_list(_npc_list:Array[NPC] = ENGINE.NpcManager.NPCS) -> NPC_FILTER:
	npc_list = _npc_list
	return self

func set_list_from_ids(id_list:Array[String]) ->NPC_FILTER:
	for id:String in id_list:
		var npc:NPC = ENGINE.NpcManager.get_npc(id)
		npc_list.append(npc)
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

func set_location(_location:Vector2=Vector2.INF) -> NPC_FILTER:
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

func set_room(_room:ROOM) -> NPC_FILTER:
	target_room = _room
	return self

func set_action_id(_action:String) -> NPC_FILTER:
	target_action_id = _action
	return self


func run_filter() -> Array[NPC]:
	# print("FILTERING check")
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
			if !npc.is_available():
				continue
			#var current_action: ACTION = npc.STATE_STACK[-1]
			#print(current_action)
			#print(current_action.CHATTABLE)
			#if !current_action.CHATTABLE:
				#continue

		if target_room != null:
			if !target_room.is_in_room(npc.LOCATION): continue

		if target_action_id != "":
			var npc_action:ACTION = npc.CURRENT_ACTION
			if npc_action != null and npc_action.ID != target_action_id: continue
			# print("class check ", npc_action.get_class())
			# if !npc_action.is_class(target_action): continue

		filtered_list.append(npc)
	#print(filtered_list)
	
	return filtered_list


#func convert_to_actions(npc_list:Array[NPC]) -> Array[ACTION]:
	#var action_list:Array[ACTION]
	#for npc:NPC in npc_list:
		#var new_action:ACTION = SocializeWithGoal.new(ENGINE).set_target(npc)
		#action_list.append(new_action)
	#return action_list


func populate_journal(menu, _engine, _subentry) -> void:
	menu.update_title("NPCs")

	if len(filtered_list) == 0:
		run_filter()

	for npc:NPC in filtered_list:
		var new_button:Button = Button.new()
		new_button.text = npc.NAME
		menu.bind_button_to_entry(new_button, npc)
		menu.add_to_entry(new_button)
