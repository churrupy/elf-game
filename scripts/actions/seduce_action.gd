extends GenericAction

class_name SeduceAction

func can_do_action():
	# also sets LOCATION
	if TARGET.ACTION != null:
		if !TARGET.ACTION.is_joinable(): return false
		if !TARGET.ACTION.is_conversable(): return false
	
	var free_tile = ENGINE.get_closest_adjacent_tile(OWNER.LOCATION, TARGET.LOCATION)
	if free_tile == null:
		return false
	LOCATION = free_tile
	return true

func score():
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
	SCORE += get_attraction()


func tick():
	update_moving_location()
	super.tick()

func do_action():
	# target hears flirt
	print("doing flirt")
	var impression = TARGET.hear_flirt(OWNER.ID)
	if impression == "pleased":
		# flirt accepted, try to find location
		var locations = ENGINE.get_node("Map").find_action_location("encounter")
		if len(locations) > 0:
			# add action entry
			var dialogue_string = OWNER.NAME + " tried to seduce " + TARGET.NAME
			var history_params = {
				"witnesses": [TARGET.ID],
				"dialogue": dialogue_string
			}
			ENGINE.History.add_entry(OWNER, "converse", LOCATION, history_params)
			dialogue_string = TARGET.NAME + " accepted the proposition!"
			history_params = {
				"witnesses": [OWNER.ID],
				"dialogue": dialogue_string
			}
			ENGINE.History.add_entry(TARGET, "converse", LOCATION, history_params)

			# create new actions for the both of them
			var chosen_location = locations.pick_random()
			var new_action = EncounterActionAnchor.new(ENGINE, "encounter")
			new_action.OWNER = TARGET
			new_action.LOCATION = chosen_location
			TARGET.ACTION = new_action

			new_action = EncounterActionNode.new(ENGINE, "encounter")
			new_action.OWNER = OWNER
			new_action.TARGET = TARGET
			# location is set dynamically based on target's location
			OWNER.ACTION = new_action
			
			return
		else:
			print("encounter location not found")
	var dialogue_string = OWNER.NAME + " flirted with " + TARGET.NAME
	var history_params = {
		"witnesses": [TARGET.ID],
		"dialogue": dialogue_string
	}
	ENGINE.History.add_entry(OWNER, "converse", OWNER.LOCATION, history_params)
	dialogue_string = TARGET.NAME + " was " + impression + " about being flirted with."
	history_params = {
		"witnesses": [OWNER.ID],
		"dialogue": dialogue_string
	}
	ENGINE.History.add_entry(TARGET, "converse", TARGET.LOCATION, history_params)
	super.do_action()



func get_attraction():
	#for testing
	return 100
