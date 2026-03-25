extends Node


#region npcs



func get_npc_from_location(location: Array):
	var npcs = []
	for npc_id in Global.NPCS:
		var npc = Global.NPCS[npc_id]
		if npc.LOCATION == location:
			npcs.append(npc_id)
	return npcs


func get_all_npc_actions():
	var npc_actions = ["converse", "flirt"]
	var all_actions = []
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]
		for npc_a in npc_actions:
			var action_data = Constants.ACTION_TEMPLATES[npc_a]
			var action_class_id = action_data["class"]
			var action_class = Constants.CLASS_TEMPLATES[action_class_id]
			var new_action = action_class.new(self, npc_a)
			#var new_action = action_data["type"].new(self, npc_a)
			new_action.TARGET = npc
			new_action.LOCATION = npc.LOCATION
			all_actions.append(new_action)
	return all_actions




func is_location_reserved(location):
	# checks if an npc already has this as a target location
	for npc_id in Global.NPCS:
		var npc = Global.NPCS[npc_id]
		if npc.ACTION != null and npc.ACTION.LOCATION == location:
			return true
	return false


#endregion


#region display

func display_list_on_screen(list, offset=0):
	for item in list:
		display_on_screen(item, offset)
		
		

func display_on_screen(item, offset=0):
	var x_index = range(Global.X_RANGE[0], Global.X_RANGE[1]).find(item.LOCATION[0])
	if x_index == -1:
		item.hide()
		return
	var y_index = range(Global.Y_RANGE[0], Global.Y_RANGE[1]).find(item.LOCATION[1])
	if y_index == -1:
		item.hide()
		return
	item.global_position[0] = (x_index * Constants.TILE_SIZE) + Constants.MAIN_FRAME_POSITION[0] + offset
	item.global_position[1] = y_index * Constants.TILE_SIZE + offset
	item.show()

#endregion
