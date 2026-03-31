class_name EncounterActionAnchor extends GenericAction

var AT_LOCATION = false
var POSE = "standing"
var ORGASM_COUNT = 0
var NODE_LOCATION # reserves a tile for node

func tick():
	if OWNER.LOCATION == LOCATION:
		#AT_LOCATION = true
		do_action()
	else:
		step_towards_location()
	
	OWNER.decay_needs()


func do_action():
	#wtf does the anchor do here lol
	# get attached nodes
	var pose_options = ENGINE.get_node("Map").get_available_poses_for_tile(LOCATION)
	POSE = pose_options.pick_random()
	var nodes = get_nodes()
	if len(nodes) == 0:
		STATUS = "finish"
	for n in nodes:
		if n.ACTION.RECENT_ACTION != null:
			var recent_action = n.ACTION.RECENT_ACTION
			var dialogue_string = OWNER.NAME + "'s " + recent_action[1] + " was used by " + n.NAME + "'s " + recent_action[0] + "."
			var history_params = {
				"witnesses": [n.ID],
				"dialogue": dialogue_string
			}
			ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, [n.ID], dialogue_string)


	var needs_refreshed = ["release", "arousal"]
	for need in needs_refreshed:
		var refresh_rate = Constants.NEED_REFRESH_RATES[need]
		OWNER.NEEDS[need] += refresh_rate
	
	if OWNER.NEEDS["arousal"] >= 100:
		var dialogue_string = OWNER.NAME + " came!"
		var witnesses = nodes.duplicate()
		var history_params = {
			"witnesses": witnesses,
			"dialogue": dialogue_string
		}
		ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, witnesses, dialogue_string)
		#STATUS = "finish"
		ORGASM_COUNT += 1
		OWNER.NEEDS["arousal"] = 50

	if have_all_nodes_orgasmed():
		flag_nodes_finished()
		for node in nodes:
			node.ACTION.flag_nodes_finished()
		STATUS = "finish"

	

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
		if npc.ACTION.TARGET is Array: continue
		if npc.ACTION.TARGET == OWNER:
			nodes.append(npc)
	return nodes
