extends RefCounted

class_name ACTION

var ENGINE
var ID: String
var OWNER: NPC
var TARGET: Node # maybe Array[Container]? to accomodate furniture/items
var LOCATION: Vector2 # this tile gets reserved by owner
var COUNTDOWN: int
var SCORE: int = 0
var STATUS: String


func _init(engine, owner: NPC, target: Node) -> void:
	ENGINE = engine
	OWNER = owner
	TARGET = target
	var action_data: Dictionary = Constants.ACTION_TEMPLATES[ID]
	COUNTDOWN = action_data["duration"]
	score()

func enter_state():
	pass

func exit_state():
	pass

func suspend_state():
	pass

func resume_state():
	pass


func score() -> void:
	pass


func can_do_action() -> bool:
	return true


func score_old() -> void:
	pass
	#extends
	# score based on need
	var action_data: Dictionary = Constants.ACTION_TEMPLATES[ID]
	var need: String = action_data["need"]
	SCORE += 100-OWNER.NEEDS[need]
	if need in ["hunger", "energy"]:
		SCORE += 10 # bonus for urgent needs


	# score based on distance
	SCORE -= OWNER.LOCATION.distance_to(LOCATION)
	'''
	total_x = abs(OWNER.LOCATION[0]- LOCATION[0])
	total_y = abs(OWNER.LOCATION[1] - LOCATION[1])
	SCORE -= (total_x + total_y)
	'''



func step_towards_location() -> void:
	#var old_location: Vector2 = OWNER.LOCATION
	var next_step: Vector2 = ENGINE.Map.step_towards_location(OWNER.LOCATION, LOCATION)
	if next_step == Vector2.INF:
		push_error("pathfinding: no valid path found, teleporting ", OWNER, " to target location")
		print("teleporting...")
		OWNER.LOCATION = LOCATION
		#ENGINE.History.add_event(OWNER.ID, "moved to", LOCATION)
	else:
		OWNER.LOCATION = next_step
		#ENGINE.History.add_event(OWNER.ID, "moved to", LOCATION)


func recheck_can_do_action():
	# what an awful bandaid lol
	if !can_do_action():
		STATUS = "finish"
		OWNER.decay_needs()
		return false
	return true


func tick() -> Array:
	if OWNER.LOCATION != LOCATION:
		#var ACTION_CLASS: GDScript = Constants.ACTION_ID["MoveAction"]
		var tile: TILE = ENGINE.Map.get_tile(LOCATION)
		var new_action: ACTION = MoveAction.new(ENGINE, OWNER, tile, ID)
		return ["add", new_action]
	if !can_do_action():
		return ["end", null]
	# recheck can-do-action, so we don't interrupt other people's actions
	var result: Array = run()
	OWNER.decay_needs()
	return result

func run() -> Array:
	# extends
	return ["running", null]
	

func update_moving_location():
	var neighbors = ENGINE.Map.get_neighbors(LOCATION)
	if LOCATION not in neighbors:
		var free_tile = ENGINE.Map.get_closest_adjacent_location(OWNER.LOCATION, LOCATION)
		if free_tile == null:
			STATUS = "finish"
		else:
			LOCATION = free_tile


func witnesses_hear(action_id: String) -> void:
	var witnesses: Array[String] = [OWNER.ID]
	if TARGET is NPC:
		witnesses += TARGET.ID

	witnesses += ENGINE.NpcManager.get_nearby_npcs(OWNER.LOCATION)

	if LOCATION != TARGET.LOCATION:
		witnesses += ENGINE.NpcManager.get_nearby_npcs(LOCATION)

	var temp_dict: Dictionary  = {}
	for w: String in witnesses:
		temp_dict[w] = 0
	witnesses = temp_dict.keys()

	if len(witnesses) == 0:
		return

	for npc_id: String in witnesses:
		pass
		#ENGINE.History.add_event("", action_id, LOCATION, witnesses)


func chitchat() -> void:
	var new_topic: String = Dialogue.get_next_topic(OWNER.RECENT_TOPIC)
	OWNER.RECENT_TOPIC = new_topic
	var opinion:int = OWNER.OPINIONS[new_topic]
	var params:Dictionary = {
		"topic": new_topic,
		"opinion": opinion
	}
	ENGINE.History.add_event(OWNER.ID, "converse", "", params)

	refresh_needs("social")



func chitchat_old() -> void:
	var center_of_conversation: Vector2 = LOCATION

	var witnesses: Array[String] = ENGINE.NpcManager.get_nearby_npcs(center_of_conversation)

	#var witnesses: Array[String] = ENGINE.get_npcs_in_range(center_of_conversation)

	if len(witnesses) < 2:
		# owner is also in witness list
		center_of_conversation = OWNER.LOCATION
		witnesses = ENGINE.NpcManager.get_nearby_npcs(center_of_conversation)

	if len(witnesses) < 2:
		# don't talk to self
		return

	witnesses.erase(OWNER.ID)

	var new_topic: String = Dialogue.get_next_topic(OWNER.RECENT_TOPIC)
	OWNER.RECENT_TOPIC = new_topic
	var opinion: int = OWNER.OPINIONS[new_topic]
	var op_str: String = OWNER.NAME + ": " + '"' + new_topic.capitalize() + " are "
	if opinion >= 3:
		op_str+= "great!"
	elif opinion >= 0:
		op_str += "okay."
	elif opinion >= -3:
		op_str += "lame."
	else:
		op_str += "terrible!"
	op_str += '"'
	#ENGINE.History.add_event(OWNER.ID, "converse", center_of_conversation, witnesses, op_str)

	refresh_needs("social")

	for npc_id: String in witnesses:
		if npc_id == OWNER.ID:
			continue
		var npc = Global.NPCS[npc_id]
		var impression: String = npc.hear_topic(OWNER.ID, new_topic, opinion)
		var _str: String = npc.NAME + " was " + impression + " with that statement."
		#ENGINE.History.add_event(npc_id, "converse", center_of_conversation, [OWNER.ID], _str)



func _to_string():
	return ID + " to " + str(TARGET) + str(LOCATION) + "(T:" + str(COUNTDOWN) + ")"

func refresh_needs(need:String) -> void:
	var refresh_rate: float = Constants.NEED_REFRESH_RATES[need]
	OWNER.NEEDS[need] += refresh_rate


#region utility

func get_nodes() -> Array[String]:
	var nodes: Array[String]
	for npc_id: String in Global.NPCS.keys():
		var npc: NPC = Global.NPCS[npc_id]
		var current_action: ACTION = npc.STATE_STACK.back()
		if current_action.TARGET == OWNER:
			nodes.append(npc_id)
	return nodes


func get_opinion():
	# dummy function
	return 0
	'''
	if TARGET in OWNER.RELATIONSHIPS:
		pass
		#return OWNER.RELATIONSHIPS[TARGET.ID]
	else:
		return 0
	'''

func get_attraction() -> int:
	#var other_style = TARGET.STYLE
	#return OWNER.OPINIONS[other_style]
	return 0

func is_joinable() -> bool:
	var action_data = Constants.ACTION_TEMPLATES[ID]
	return action_data["joinable"]

func is_conversable() -> bool:
	var action_data = Constants.ACTION_TEMPLATES[ID]
	if "conversable" in action_data: return false
	return true

func can_do_off_tile() -> bool:
	var action_data: Dictionary = Constants.ACTION_TEMPLATES[ID]
	return action_data["do_off_tile"]


#endregion
