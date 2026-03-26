class_name EncounterActionNode extends GenericAction

var POSE = "standing"
var ORIENTATION = "front"
var RECENT_ACTION

const gender = {
	"male": ["hands", "mouth", "penis"],
	"female": ["hands", "mouth", "vagina"]
}

func tick():
	LOCATION = TARGET.LOCATION.duplicate()

	var neighbors = ENGINE.get_neighbors(LOCATION)
	if OWNER.LOCATION in neighbors:
		if TARGET.ACTION.AT_LOCATION:
			do_action()
	else:
		step_towards_target()

	OWNER.decay_needs()
	OWNER.clamp_needs()

func do_action():
	# pick an action
	# display it
	var pose = [POSE, ORIENTATION, TARGET.ACTION.POSE]
	RECENT_ACTION = determine_action(pose).pick_random()
	var dialogue_string = OWNER.NAME + " used their " + RECENT_ACTION[0] + " on " + TARGET.NAME + "'s " + RECENT_ACTION[1] + "."
	var history_params = {
		"witnesses": [TARGET.ID],
		"dialogue": dialogue_string
	}
	ENGINE.History.add_entry(OWNER, "converse", OWNER.LOCATION, history_params)

	COUNTDOWN -= 1
	var action_need = "release"
	var refresh_rate = Constants.NEED_REFRESH_RATES[action_need]
	OWNER.NEEDS[action_need] += refresh_rate

	if COUNTDOWN < 0:
		STATUS = "finish"

	# process arousal here


func determine_action(pose):
	var action_list = EncounterActions.POSES[pose]
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
