class_name EncounterActionNode extends ACTION

#var POSE:String = "standing"
var ORIENTATION: String = "front"
#var RECENT_ACTION: Array
var ORGASM_COUNT: int = 0

const GENDER_TEMPLATES: Dictionary = {
	"male": ["hands", "mouth", "penis"],
	"female": ["hands", "mouth", "vagina"]
}

func _init(engine, owner: NPC, target: NPC) -> void:
	ID = "encounter"
	super._init(engine, owner, target)
	# no scoring needed
	# LOCATION has to be manually set by whatever is initializing this class


func run() -> ActionResult:
	# wait for target to get to location
	var target_action: ACTION = TARGET.STATE_STACK.back()
	if target_action is not EncounterActionAnchor:
		# target isn't to location yet
		return ActionResult.new("running", null)
		#return ["running", null]

	# pick an action
	# display it
	var pose_options: Array = ENGINE.Map.get_available_poses_for_tile(LOCATION)
	POSE = pose_options.pick_random()


	var pose_data: Array = [POSE, ORIENTATION, target_action.POSE]
	#RECENT_ACTION = determine_action(pose_data).pick_random()
	#var dialogue_string = OWNER.NAME + " used their " + RECENT_ACTION[0] + " on " + TARGET.NAME + "'s " + RECENT_ACTION[1] + "."
	#ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, [TARGET.ID], dialogue_string)

	var needs_refreshed: Array[String] = ["release", "arousal"]
	for need: String in needs_refreshed:
		refresh_needs(need)

	check_orgasm()
	if ORGASM_COUNT > 0:
		if target_action.ORGASM_COUNT > 0:
			var nodes: Array[String] = get_nodes()
			if len(nodes) == 0:
				# can quit encounter when target has orgasmed at least once and node has no nodes attached to it
				return ActionResult.new("end", null)
				#return ["end", null]
	return ActionResult.new("running", null)
	#return ["running", null]

	

func check_orgasm() -> void:
	if OWNER.NEEDS["arousal"] >= 100:
		var dialogue_string = OWNER.NAME + " came!"
		var witnesses: Array[String] = get_nodes()
		witnesses.append(TARGET.ID)
		#ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, witnesses, dialogue_string)
		ORGASM_COUNT += 1
		OWNER.NEEDS["arousal"] = 50


func determine_action(pose_data:Array) -> Array:
	# holy shit this is bad lol
	var action_list: Array = EncounterActions.POSES[pose_data]
	var valid_actions: Array
	for action: Array in action_list:
		var owner_gender: String = OWNER.GENDER
		var owner_body: Array = GENDER_TEMPLATES[owner_gender]
		if action[0] not in owner_body: continue
		var target_gender: String = TARGET.GENDER
		var target_body: Array = GENDER_TEMPLATES[target_gender]
		if action[1] not in target_body: continue
		valid_actions.append(action)
	return valid_actions
