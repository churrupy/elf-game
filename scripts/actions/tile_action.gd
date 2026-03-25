extends GenericAction
# action that takes place on a tile
class_name TileAction


func score():
	# score based on need
	var action_data = Constants.ACTION_TEMPLATES[ID]
	var need = action_data["need"]
	SCORE += 100-OWNER.NEEDS[need]
	if need in ["hunger", "energy"]:
		SCORE += 10 # bonus for urgent needs

	# score based on distance
	var total_x
	var total_y
	# target is always array
	total_x = abs(LOCATION[0]- TARGET[0])
	total_y = abs(LOCATION[1] - TARGET[1])
	SCORE -= (total_x + total_y)


func can_do_action():
	# target is a location
	var is_reserved = Utility.is_location_reserved(LOCATION)
	var is_travelable = ENGINE.get_node("Map").is_travelable(LOCATION)

	if is_reserved or !is_travelable:
		if !can_do_off_tile(): return false
		var neighbors = ENGINE.get_neighbors(LOCATION)
		for n in neighbors:
			is_reserved = Utility.is_location_reserved(n)
			is_travelable = ENGINE.get_node("Map").is_travelable(n)
			if !is_reserved and is_travelable:
				LOCATION = n
				return true
		return false
	else:
		return true


func do_action():
	ENGINE.History.add_entry(OWNER.ID, ID, LOCATION)

	super.do_action()
