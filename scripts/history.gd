extends Node

class_name HISTORY_CLASS

var HISTORY = []



func _ready() -> void:
	pass


func _process(delta:float):
	pass


func add_entry(npc, action, arg=null):
	var history_dict = {
		"tick": Global.TICKS,
		"npc": npc,
		"action": action,
		"arg": arg
	}
	HISTORY.append(history_dict)


func filter_by_npc(npc):
	var filtered_history = []
	for h in HISTORY:
		if h["npc"] == npc:
			filtered_history.append(h)

	return filtered_history

func display_history(history_list = []):
	if history_list == []:
		history_list = HISTORY
	var display_list = []
	for h in history_list:
		var _str = "Tick " + str(h["tick"]) + ": " + h["npc"] + " " + h["action"]
		if h["arg"] != null:
			_str += " to " + str(h["arg"])
		display_list.append(_str)
	return display_list
