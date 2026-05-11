class_name HISTORY_CLASS extends Control

var ENGINE
var HISTORY: Array[EVENT_new]


func _init(engine):
	ENGINE = engine

func add_event() -> void:
	# steps
	# create event
	# populate event information
	# check that event doesn't already exist
	# add event
	pass

func create_event(_action:ACTION) -> void:
	var existing_event:EVENT_new = get_existing_event(_action)
	if existing_event != null:
		# do something
		existing_event.END_TICK = Global.TICKS
	else:
		var new_event:EVENT_new = EVENT_new.new(_action)
		#var current_room:ROOM = ENGINE.Map.get_room(new_event.LOCATION)
		#new_event.ROOM = current_room
		HISTORY.append(new_event)
	
	broadcast_action(_action)

func get_existing_event(_action:ACTION) -> EVENT_new:
	for event:EVENT_new in HISTORY:
		if _action.is_equal(event): return event
	return null

	

func broadcast_action(_action:ACTION) -> void:
	var _witnesses:Array[NPC] = []

	if _action.HEARABLE:
		var filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().in_range_of(_action.OWNER.LOCATION, 2)
		var hearing_npcs:Array[NPC] = filter.run_filter()
		_witnesses += hearing_npcs
	
	if _action.SEEABLE:
		var filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().in_range_of(_action.OWNER.LOCATION, 10).looking_at()
		var seeing_npcs:Array[NPC] = filter.run_filter()
		_witnesses += seeing_npcs

	var witness_list:Array[NPC]
	for npc:NPC in _witnesses:
		if npc not in witness_list:
			npc.create_memory(_action)
			# event.process_involvement(npc)
			witness_list.append(npc)


func populate_talk_menu(npc_id:String) -> Array[String]:
	return []

func populate_npc_menu(npc_id:String) -> Array[String]:
	return []


func does_event_exist(actor_id:String, action_id:String, target_id:String) -> int:
	var event_index:int = HISTORY.find_custom(func(event): return event.ACTOR==actor_id and event.ACTION_ID == action_id and event.TARGET == target_id)
	return event_index
	


func event_strings(history_list:Array[EVENT_new] = HISTORY) -> Array[String]:
	var display_list:Array[String]
	for event:EVENT_new in history_list:
		display_list.append(str(event))
	return display_list

func history_to_string(history_list: Array =[]) -> Array:
	if history_list == []:
		history_list = HISTORY
	var display_list: Array = []
	for h in history_list:
		var _str: String = "Tick {tick}: {location} {npc} {action}"
		if len(h.WITNESSES) > 0:
			_str += " with {witnesses}"
		_str = _str.format({
			"tick": h.TICK,
			"location": str(h.LOCATION),
			"npc": h.NPC_ID,
			"action": h.ACTION_ID,
			"witnesses": h.WITNESSES
		})
		display_list.append(_str)
	return display_list
 
