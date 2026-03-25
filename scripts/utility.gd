extends Node


#region npcs



func get_npc_from_location(location: Array):
	var npcs = []
	for npc_id in Global.NPCS:
		var npc = Global.NPCS[npc_id]
		if npc.LOCATION == location:
			npcs.append(npc_id)
	return npcs


func get_all_group_actions():
	var all_actions = []
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]
		if npc.ACTION == null: continue
		if not npc.ACTION.is_joinable(): continue
		var new_action = ACTIONS.new()
		new_action.ID = npc.ACTION.ID
		new_action.TARGET = npc.ACTION.TARGET
		new_action.LOCATION = npc.ACTION.LOCATION
		new_action.NEED = npc.ACTION.NEED
		new_action.FOLLOWING = npc
		all_actions.append(new_action)
	return all_actions



func is_location_reserved_by_occupant(location):
	for npc_id in Global.NPCS:
		var npc = Global.NPCS[npc_id]
		if npc.ACTION == null: continue
		if npc.LOCATION == location and npc.LOCATION == npc.ACTION.LOCATION:
			return true
	return false

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
	#print(item)
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
