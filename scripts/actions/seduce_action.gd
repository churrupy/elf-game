extends GenericAction

class_name SeduceAction

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

func get_attraction():
	#for testing
	return 100


func can_do_action():
	if TARGET.ACTION != null:
		if !TARGET.ACTION.is_joinable(): return false
		if !TARGET.ACTION.is_conversable(): return false
	else:
		# decide encounter locations on action, because npc needs to move to target first and encounter locations may end up reserving/unreserving in the meantime
		return true

func tick():
	print("hello?")
	LOCATION = TARGET.LOCATION.duplicate()

	var neighbors = ENGINE.get_neighbors(LOCATION)
	if OWNER.LOCATION in neighbors:
		do_action()
	else:
		step_towards_target()

	OWNER.decay_needs()
	OWNER.clamp_needs()

func do_action():
	# target hears flirt
	print("doing flirt")
	var impression = TARGET.hear_flirt(OWNER.ID)
	if impression == "pleased":
		# flirt accepted, try to find location
		var locations = ENGINE.get_node("Map").find_action_location("encounter")
		if len(locations) > 0:
			print("encounter location found")
			var chosen_location = locations.pick_random()
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
			
			var new_action = EncounterActionNode.new(ENGINE, "encounter")
			new_action.OWNER = OWNER
			new_action.TARGET = TARGET
			new_action.LOCATION = TARGET.LOCATION
			OWNER.ACTION = new_action
			new_action = EncounterActionAnchor.new(ENGINE, "encounter")
			new_action.OWNER = TARGET
			#new_action.TARGET = OWNER
			new_action.LOCATION = chosen_location
			TARGET.ACTION = new_action
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
