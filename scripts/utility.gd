extends Node

# class_name Utility



#region npcs


func get_npc_from_location(location: Vector2) -> Array[String]:
	var npcs: Array[String]
	for npc_id: String in Global.NPCS.keys():
		var npc: NPC = Global.NPCS[npc_id]
		if npc.LOCATION == location:
			npcs.append(npc_id)
	return npcs

func is_location_reserved(loc: Vector2) -> bool:
	for npc_id: String in Global.NPCS:
		var npc: NPC = Global.NPCS[npc_id]
		var current_action_loc = npc.STATE_STACK.back().LOCATION
		if current_action_loc == loc: return true
		#if npc.ACTION != null and npc.ACTION.LOCATION == loc: return true
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
