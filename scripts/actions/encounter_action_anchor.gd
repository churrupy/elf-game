class_name EncounterActionAnchor extends ACTION

# target is a tile/location

var POSE = "standing"
var ORGASM_COUNT = 0

func _init(engine, owner: NPC, target: TILE) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "encounter"
	LOCATION = target.LOCATION
	super._init(engine, owner, target)


func run() -> Array:
	#wtf does the anchor do here lol
	# get attached nodes
	var pose_options: Array = ENGINE.Map.get_available_poses_for_tile(LOCATION)
	POSE = pose_options.pick_random()

	var nodes: Array[String] = get_nodes()
	if len(nodes) == 0:
		return ["end", null]

	var interacted_with: bool = false
	for npc_id:String in nodes:
		var npc:NPC = Global.NPCS[npc_id]
		var recent_action: ACTION = npc.STATE_STACK.back()
		if recent_action.ID != "encounter" or recent_action.RECENT_ACTION == []:
			continue # still getting to location
		interacted_with = true
		var current_action:Array = recent_action.RECENT_ACTION
		var dialogue_string: String = OWNER.NAME + "'s " + current_action[1] + " was used by " + npc.NAME + "'s " + current_action[0] + "."
		ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, [npc_id], dialogue_string)
		
	if interacted_with:
		var needs_refreshed: Array[String] = ["release", "arousal"]
		for need: String in needs_refreshed:
			refresh_needs(need)
		check_orgasm()

	return ["running", null]
	

func check_orgasm() -> void:
	if OWNER.NEEDS["arousal"] >= 100:
		var dialogue_string = OWNER.NAME + " came!"
		var witnesses: Array[String] = get_nodes()
		ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, witnesses, dialogue_string)
		ORGASM_COUNT += 1
		OWNER.NEEDS["arousal"] = 50
