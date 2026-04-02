extends Node

class_name HISTORY_CLASS

var ENGINE
var HISTORY: Array[HISTORY_EVENT]

func _init(engine):
	ENGINE = engine

func _ready() -> void:
	pass


func _process(delta:float):
	pass


func add_event(npc_id: String, action: String, location: Vector2, witnesses: Array = [], dialogue: String = "") -> void:
	var new_event = HISTORY_EVENT.new()
	new_event.TICK = Global.TICKS
	new_event.NPC_ID = npc_id
	new_event.ACTION = action
	new_event.LOCATION = location
	var index: int = witnesses.find(npc_id)
	if index > -1:
		witnesses.remove_at(index)
	new_event.WITNESSES = witnesses
	new_event.DIALOGUE = dialogue
	HISTORY.append(new_event)


func add_entry(npc, action, location, arg={}):
	if npc is NPC:
		npc = npc.ID
	var history_dict = {
		"tick": Global.TICKS,
		"npc": npc,
		"action": action,
		"location": location,
		"arg": arg
	}
	HISTORY.append(history_dict)

func filter_by_doer_old(npc):
	# actions npc does
	if npc is NPC:
		npc = npc.ID
	var filtered_history = []
	for h in HISTORY:
		if h.NPC == npc:
			filtered_history.append(h)
	return filtered_history

func filter_by_doer(npc_id: String) -> Array[HISTORY_EVENT]:
	# filter by initiator of event
	return HISTORY.filter(func(event): return event.NPC_ID == npc_id)


func filter_by_npc(npc_id: String) -> Array[HISTORY_EVENT]:
	# filter by whether npc is involved in event (whether doer or witness)
	return HISTORY.filter(func(event): return (event.NPC_ID == npc_id) or (npc_id in event.WITNESSES))

func filter_by_npc_old(npc):
	# actions npc is either doer or target
	if npc is NPC:
		npc = npc.ID
	var filtered_history = []
	for h in HISTORY:
		if h["npc"] == npc:
			filtered_history.append(h)
		elif "witnesses" in h["arg"]:
			if npc in h["arg"]["witnesses"]:
				filtered_history.append(h)

	return filtered_history

func filter_by_location(location: Array) -> Array:
	if location == null:
		return []
	return HISTORY.filter(func(event): event.LOCATION == location)

func filter_by_location_old(location):
	if location == null:
		return []
	var filtered_history = []
	for h in HISTORY:
		if h["location"] == location:
			filtered_history.append(h)
	return filtered_history

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
			"action": h.ACTION,
			"witnesses": h.WITNESSES
		})
		display_list.append(_str)
	return display_list




func history_to_string_old(history_list = []):
	if history_list == []:
		history_list = HISTORY
	var display_list = []
	for h in history_list:
		var _str = "Tick " + str(h["tick"]) + ": " + str(h["location"]) + " " + h["npc"] + " " + h["action"]
		if "location" in h["arg"]:
			var location_str = " to " + str(h["arg"]["location"])
			_str += location_str
		if "witnesses" in h["arg"]:
			var group_str = " with " + ",".join(h["arg"]["witnesses"]) + "."
			_str += group_str
		'''
		if "dialogue" in h["arg"]:
			var dialogue_str = h["arg"]["dialogue"]
			_str += dialogue_str
		'''
		display_list.append(_str)
	return display_list
