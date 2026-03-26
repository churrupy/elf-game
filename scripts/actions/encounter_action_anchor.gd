class_name EncounterActionAnchor extends GenericAction

var AT_LOCATION = false
var POSE = "standing"

func tick():
	if OWNER.LOCATION == LOCATION:
		AT_LOCATION = true
		do_action()
	else:
		step_towards_target()
	
	OWNER.decay_needs()
	OWNER.clamp_needs()
	if TARGET is NPC: #figure out a better way to do this later lol
		LOCATION = TARGET.LOCATION.duplicate()

		var neighbors = ENGINE.get_neighbors(LOCATION)
		if OWNER.LOCATION in neighbors:
			do_action()


func do_action():
	#wtf does the anchor do here lol
	# get attached nodes
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
			ENGINE.History.add_entry(OWNER, "converse", OWNER.LOCATION, history_params)




	# no countdown because is dependent on nodes for completion
	var action_need = "release"
	var refresh_rate = Constants.NEED_REFRESH_RATES[action_need]
	OWNER.NEEDS[action_need] += refresh_rate

func get_nodes():
	var nodes = []
	for npc_id in Global.NPCS.keys():
		var npc = Global.NPCS[npc_id]
		if npc.ACTION == null: continue
		if npc.ACTION.TARGET == OWNER:
			nodes.append(npc)
	return nodes
