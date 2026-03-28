class_name EncounterActionNode extends GenericAction

var POSE = "standing"
var ORIENTATION = "front"
var RECENT_ACTION
var ORGASM_COUNT = 0

const gender = {
	"male": ["hands", "mouth", "penis"],
	"female": ["hands", "mouth", "vagina"]
}

func tick():
	# set action location
	if OWNER.LOCATION != LOCATION:
		step_towards_location()
	if TARGET.LOCATION == TARGET.ACTION.LOCATION:
		do_action()
	# if target not at location, just, like, vibe or something man
	OWNER.decay_needs()
	return


	
	var target_neighbors = ENGINE.get_neighbors(TARGET.ACTION.LOCATION)
	if OWNER.LOCATION not in target_neighbors:
		LOCATION = ENGINE.get_closest_adjacent_tile(OWNER.LOCATION, TARGET.LOCATION)
		if LOCATION == null:
			STATUS = "finish"
			return
		step_towards_location()
		OWNER.decay_needs()
	else:
		if TARGET.ACTION.AT_LOCATION:
			do_action()
			OWNER.decay_needs()

func do_action():
	# pick an action
	# display it
	var pose_options = ENGINE.get_node("Map").get_available_poses_for_tile(LOCATION)
	POSE = pose_options.pick_random()
	var pose_data = [POSE, ORIENTATION, TARGET.ACTION.POSE]
	RECENT_ACTION = determine_action(pose_data).pick_random()
	var dialogue_string = OWNER.NAME + " used their " + RECENT_ACTION[0] + " on " + TARGET.NAME + "'s " + RECENT_ACTION[1] + "."
	var history_params = {
		"witnesses": [TARGET.ID],
		"dialogue": dialogue_string
	}
	ENGINE.History.add_entry(OWNER, "converse", OWNER.LOCATION, history_params)

	COUNTDOWN -= 1
	var needs_refreshed = ["release", "arousal"]
	for need in needs_refreshed:
		var refresh_rate = Constants.NEED_REFRESH_RATES[need]
		OWNER.NEEDS[need] += refresh_rate
	
	if OWNER.NEEDS["arousal"] >= 100:
		dialogue_string = OWNER.NAME + " came!"
		var witnesses = get_nodes()
		witnesses.append(TARGET.ID)
		history_params = {
			"witnesses": witnesses,
			"dialogue": dialogue_string
		}
		ENGINE.History.add_entry(OWNER, "converse", OWNER.LOCATION, history_params)
		ORGASM_COUNT += 1
		OWNER.NEEDS["arousal"] = 50


	if COUNTDOWN < 0:
		STATUS = "finish"

	# process arousal here


func determine_action(pose_data):
	var action_list = EncounterActions.POSES[pose_data]
	var valid_actions = []
	for action in action_list:
		var owner_gender = OWNER.GENDER
		var owner_body = gender[owner_gender]
		if action[0] not in owner_body: continue
		var target_gender = TARGET.GENDER
		var target_body = gender[target_gender]
		if action[1] not in target_body: continue
		valid_actions.append(action)
	return valid_actions

func flag_nodes_finished():
	var nodes = get_nodes()
	for node in nodes:
		node.ACTION.flag_nodes_finished()
	STATUS = "finish"

func have_all_nodes_orgasmed():
	var nodes = get_nodes()
	for node in nodes:
		if node.ACTION.ID != "encounter": continue
		if node.ACTION.have_all_nodes_orgasmed() == false:
			return false
	if ORGASM_COUNT == 0:
		return false
	return true


func get_nodes():
	var nodes = []
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]
		if npc.ACTION == null: continue
		if npc.ACTION.TARGET == OWNER:
			nodes.append(npc)
	return nodes
