class_name ACTION extends RefCounted

var ENGINE
var ID: String
var OWNER: NPC
var TARGET: Node # maybe Array[Container]? to accomodate furniture/items
var LOCATION: Vector2 # this tile gets reserved by owner
var COUNTDOWN: int
var SCORE: int = 0
var STATUS: String

var CHATTABLE: bool = true


var POSE:String = "standing"
var PHYSICAL_ACTION:String = ""


func _init(engine, owner: NPC, target: Node) -> void:
	ENGINE = engine
	OWNER = owner
	TARGET = target
	var action_data: Dictionary = Constants.ACTION_TEMPLATES[ID]
	COUNTDOWN = action_data["duration"]
	score()

func enter_state():
	pass

func exit_state() -> ACTION:
	if PHYSICAL_ACTION != "":
		var new_action:ACTION = SocialAction.new(ENGINE, OWNER, TARGET)
		new_action.PHYSICAL_ACTION = PHYSICAL_ACTION
		return new_action
	return null

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


func tick() -> ActionResult:
	if OWNER.LOCATION != LOCATION:
		#var ACTION_CLASS: GDScript = Constants.ACTION_ID["MoveAction"]
		var tile: TILE = ENGINE.Map.get_tile(LOCATION)
		var new_action: ACTION = MoveAction.new(ENGINE, OWNER, tile, ID)
		return ActionResult.new("add", new_action)
		#return ["add", new_action]
	if !can_do_action():
		return ActionResult.new("end", null)
		#return ["end", null]
	# recheck can-do-action, so we don't interrupt other people's actions
	#var result:ActionResult = ActionResult.new("running", null)
	var result:ActionResult = run()
	OWNER.decay_needs()
	return result

func run() -> ActionResult:
	# extends
	return ActionResult.new("running", null)
	#return ["running", null]
	

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
	#flirt()
	var new_topic: String = Dialogue.get_next_topic(OWNER.RECENT_TOPIC)
	OWNER.RECENT_TOPIC = new_topic
	OWNER.SOCIAL_ACTION.RECENT_TOPIC = new_topic
	var opinion:int = OWNER.OPINIONS[new_topic]
	var params:Dictionary = {
		"topic": new_topic,
		"opinion": opinion
	}
	ENGINE.History.add_event(OWNER.ID, "converse", "", params)

	refresh_needs("social")

func flirt() -> void:
	# deal with being target of escalation
	print("flirting hit")
	var nodes:Array[String] = get_nodes()
	if len(nodes) > 0:
		# target
		# right now just assume that being targeted automatically means escalation
		# i'll figure out the details later
		for node:String in nodes:
			# decide whether to rebuff them
			var attraction:int = ENGINE.NpcManager.get_attraction(OWNER.ID, node)
			if attraction < 0:
				ENGINE.History.add_event(OWNER.ID, "rebuff", node)
	
	if PHYSICAL_ACTION != "":
		print("physical action", PHYSICAL_ACTION)
		if OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
			# target moved away
			TARGET = null
		var event_index:int = ENGINE.History.does_event_exist(TARGET.ID, "rebuff", OWNER.ID)
		if event_index > -1:
			PHYSICAL_ACTION == ""
		else:
			# try to escalate
			if PHYSICAL_ACTION in Dialogue.ENCOUNTER_ESCALATION:
				print("escalating")
				PHYSICAL_ACTION = Dialogue.ENCOUNTER_ESCALATION[PHYSICAL_ACTION]
				ENGINE.History.add_event(OWNER.ID, PHYSICAL_ACTION, TARGET.ID)

	elif (OWNER.NEEDS["release"] < 50 or OWNER.NEEDS["arousal"] > 30):
		print("target:", TARGET)
		print(TARGET is NPC)
		if TARGET is not NPC:
			var nearby_npcs:Array[String] = ENGINE.NpcManager.get_nearby_npcs(OWNER.LOCATION)
			var highest_attraction: int = 0
			var most_attractive_npc:String = ""
			for npc_id:String in nearby_npcs:
				if npc_id == OWNER.ID: continue
				#var npc:NPC = Global.NPCS[npc_id]
				var attraction:int = ENGINE.NpcManager.get_attraction(OWNER.ID, npc_id)
				if attraction > highest_attraction:
					#var event_index:int = ENGINE.History.does_event_exist(npc_id, "rebuff", OWNER.ID) #assumes that target npc will never change their mind (though i really should put expiration dates on the events lol)
					highest_attraction = attraction
					most_attractive_npc = npc_id
			if most_attractive_npc != "":
				print("found attractive", most_attractive_npc)
				TARGET = Global.NPCS[most_attractive_npc]
		else:
			# let's start with this
			PHYSICAL_ACTION = "sweet nothings"
			ENGINE.History.add_event(OWNER.ID, PHYSICAL_ACTION, TARGET.ID)


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
	OWNER.SOCIAL_ACTION.RECENT_TOPIC = new_topic
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
