extends Node


#region tile

func calc_distance(loc1, loc2):
	var x_diff = abs(loc1[0] - loc2[0]) * 1.0
	var y_diff = abs(loc1[1] - loc2[1]) * 1.0
	if x_diff == 0:
		return y_diff
	if y_diff == 0:
		return x_diff
	return y_diff/x_diff


#endregion


#region npcs

func filter_reserved_tiles(tile_list):
	var free_tiles = []
	for tile in tile_list:
		if is_location_reserved(tile): continue
		free_tiles.append(tile)
	return free_tiles

func get_npc_from_location(location: Array):
	var npcs = []
	for npc_id in Global.NPCS:
		var npc = Global.NPCS[npc_id]
		if npc.LOCATION == location:
			npcs.append(npc_id)
	return npcs



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
