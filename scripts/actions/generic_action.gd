extends RefCounted

class_name GenericAction

var ENGINE
var ID
var OWNER
var TARGET
var LOCATION # this tile gets reserved by owner
var COUNTDOWN
var SCORE = 0
var STATUS


func _init(engine, action_id):
	ENGINE = engine
	#OWNER = owner
	ID = action_id
	var action_data = Constants.ACTION_TEMPLATES[ID]
	COUNTDOWN = action_data["duration"]


func can_do_action():
	if TARGET is NPC:
		if TARGET.ACTION != null:
			var encounter_flag = false
			if TARGET.ACTION.ID == "encounter":
				encounter_flag = true
			if !TARGET.ACTION.is_joinable(): return false
			if !TARGET.ACTION.is_conversable(): return false
			if encounter_flag:
				push_error("ENCOUNTER PASSED CAN DO ACTION")

		var free_tile = ENGINE.get_closest_adjacent_tile(OWNER.LOCATION, TARGET.LOCATION)
		if free_tile == null:
			return false
		LOCATION = free_tile
		return true
	else:
		# target is a location
		var is_reserved = Utility.is_location_reserved(TARGET)
		var is_travelable = ENGINE.get_node("Map").is_travelable(TARGET)

		if is_reserved or !is_travelable:
			if !can_do_off_tile(): return false
			var free_tile = ENGINE.get_closest_adjacent_tile(OWNER.LOCATION, TARGET)
			if free_tile == null:
				return false
			LOCATION = free_tile
			return true
		else:
			return true


func score():
	# score based on need
	var action_data = Constants.ACTION_TEMPLATES[ID]
	var need = action_data["need"]
	SCORE += 100-OWNER.NEEDS[need]
	if need in ["hunger", "energy"]:
		SCORE += 10 # bonus for urgent needs

	# score based on preference
	if TARGET is NPC:
		if OWNER == TARGET:
			SCORE = -100
			return
		SCORE += get_opinion()
		if ID == "flirt":
			SCORE += get_attraction()

	# score based on distance
	var total_x
	var total_y
	if TARGET is Array:
		total_x = abs(LOCATION[0]- TARGET[0])
		total_y = abs(LOCATION[1] - TARGET[1])
	else:
		total_x = abs(LOCATION[0] - TARGET.LOCATION[0])
		total_y = abs(LOCATION[1] - TARGET.LOCATION[1])
	SCORE -= (total_x + total_y)




func step_towards_location():
	var old_location = OWNER.LOCATION.duplicate()
	var next_step = ENGINE.get_node("Map").step_towards_location(OWNER.LOCATION, LOCATION)
	if next_step == null:
		push_error("pathfinding: no valid path found, teleporting ", OWNER, " to target location")
		print("teleporting...")
		OWNER.LOCATION = LOCATION
		ENGINE.History.add_entry(OWNER.ID, "teleported to", old_location, {"location": LOCATION})
	else:
		OWNER.LOCATION = next_step
		ENGINE.History.add_entry(OWNER.ID, "moved to", old_location, {"location": next_step})


func recheck_can_do_action():
	# what an awful bandaid lol
	if !can_do_action():
		STATUS = "finish"
		OWNER.decay_needs()
		return false
	return true


func tick():
	# target is a travelable tile (just a location array)
	#if !recheck_can_do_action():
	#	return
	if OWNER.LOCATION == LOCATION:
		do_action()
	else:
		step_towards_location()
	OWNER.decay_needs()
	

func update_moving_location():
	var neighbors = ENGINE.get_neighbors(TARGET.LOCATION)
	if LOCATION not in neighbors:
		var free_tile = ENGINE.get_closest_adjacent_tile(OWNER.LOCATION, TARGET.LOCATION)
		if free_tile == null:
			STATUS = "finish"
		else:
			LOCATION = free_tile


func do_action():
	COUNTDOWN -= 1
	var action_need = Constants.ACTION_TEMPLATES[ID]["need"]
	var refresh_rate = Constants.NEED_REFRESH_RATES[action_need]
	OWNER.NEEDS[action_need] += refresh_rate

	if is_conversable():
		converse()

	if COUNTDOWN < 0:
		STATUS = "finish"


func converse():
	var center_of_conversation = TARGET
	if TARGET is not Array:
		center_of_conversation = TARGET.LOCATION

	var witnesses = ENGINE.get_npcs_in_range(center_of_conversation)

	if len(witnesses) < 2:
		# owner is also in witness list
		center_of_conversation = OWNER.LOCATION
		witnesses = ENGINE.get_npcs_in_range(center_of_conversation)

	if len(witnesses) < 2:
		# don't talk to self
		return

	witnesses.erase(OWNER)

	var new_topic = Dialogue.get_next_topic(OWNER.RECENT_TOPIC)
	OWNER.RECENT_TOPIC = new_topic
	var opinion = OWNER.OPINIONS[new_topic]
	var op_str = OWNER.NAME + ": " + '"' + new_topic.capitalize() + " are "
	if opinion >= 3:
		op_str+= "great!"
	elif opinion >= 0:
		op_str += "okay."
	elif opinion >= -3:
		op_str += "lame."
	else:
		op_str += "terrible!"
	op_str += '"'
	var history_params = {
		"dialogue": op_str,
		"witnesses": witnesses
	}
	ENGINE.History.add_entry(OWNER, "converse", center_of_conversation, history_params)

	for g in witnesses:
		if g == OWNER.ID:
			continue
		var g_npc = Global.NPCS[g]
		var impression = g_npc.hear_topic(OWNER.ID, new_topic, opinion)
		var _str = g_npc.NAME + " was " + impression + " with that statement."
		history_params = {
			"dialogue": _str,
			"witnesses": [OWNER.ID]
		}
		ENGINE.History.add_entry(g, "converse", center_of_conversation, history_params)



func _to_string():
	return ID + " " + str(LOCATION) + "(T:" + str(COUNTDOWN) + ")"


#region utility

func get_opinion():
	# dummy function
	if TARGET in OWNER.RELATIONSHIPS:
		return OWNER.RELATIONSHIPS[TARGET.ID]
	else:
		return 0

func get_attraction():
	var other_style = TARGET.STYLE
	return OWNER.OPINIONS[other_style]

func is_joinable():
	var action_data = Constants.ACTION_TEMPLATES[ID]
	return action_data["joinable"]

func is_conversable():
	var action_data = Constants.ACTION_TEMPLATES[ID]
	if "conversable" in action_data: return false
	return true

func can_do_off_tile():
	var action_data = Constants.ACTION_TEMPLATES[ID]
	return action_data["do_off_tile"]


#endregion
