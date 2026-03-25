extends Node

class_name HISTORY_CLASS

var HISTORY = []



func _ready() -> void:
	pass


func _process(delta:float):
	pass


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


func filter_by_npc(npc):
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

func filter_by_location(location):
	if location == null:
		return []
	var filtered_history = []
	for h in HISTORY:
		if h["location"] == location:
			filtered_history.append(h)
	return filtered_history

func display_history(history_list = []):
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
		if "dialogue" in h["arg"]:
			var dialogue_str = h["arg"]["dialogue"]
			_str += dialogue_str
		display_list.append(_str)
	return display_list
