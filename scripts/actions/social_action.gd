extends GenericAction
# TARGET is always an object with .LOCATION
class_name SocialAction

func can_do_action():
	# also sets LOCATION
	if TARGET.ACTION != null:
		if !TARGET.ACTION.is_joinable(): return false
		if !TARGET.ACTION.is_conversable(): return false
	
	var free_tile = ENGINE.get_node("Map").get_closest_adjacent_tile(OWNER.LOCATION, TARGET.LOCATION)
	if free_tile == null:
		return false
	LOCATION = free_tile
	return true

func score():
	# score based on need
	var action_data = Constants.ACTION_TEMPLATES[ID]
	var need = action_data["need"]
	SCORE += 100-OWNER.NEEDS[need]
	if need in ["hunger", "energy"]:
		SCORE += 10 # bonus for urgent needs

	# score based on preference
	if OWNER == TARGET:
		SCORE = -100
		return
	SCORE += get_opinion()
	if ID == "flirt":
		SCORE += get_attraction()

	# distance isn't taken into account just yet
	# eventually npcs will prioritize people in the same room/building and not running off across the map to socialize

func tick():
	if !recheck_can_do_action():
		return
	update_moving_location()
	super.tick()

func do_action():

	var dialogue_string = OWNER.NAME + " flirted with " + TARGET.NAME
	var history_params = {
		"witnesses": [TARGET.ID],
		"dialogue": dialogue_string
	}
	ENGINE.History.add_entry(OWNER, "converse", OWNER.LOCATION, history_params)
	var impression = TARGET.hear_flirt(OWNER.ID)
	dialogue_string = TARGET.NAME + " was " + impression + " about being flirted with."
	history_params = {
		"witnesses": [OWNER.ID],
		"dialogue": dialogue_string
	}
	ENGINE.History.add_entry(TARGET, "converse", TARGET.LOCATION, history_params)


	super.do_action() # does need refresh and countdown
