class_name IdleAction extends ACTION

# this class does determine_action

func _init(engine, owner: NPC, target: Node) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "idle"
	LOCATION = owner.LOCATION
	super._init(engine, owner, target)

func can_do_action() -> bool:
	return true


func run():
	print("running")
	LOCATION = OWNER.LOCATION # keeps in place for idling
	var all_actions: Array[ACTION] = ENGINE.Map.get_all_actions_on_map(OWNER)
	all_actions += ENGINE.NpcManager.get_all_npc_actions(OWNER)
	all_actions.sort_custom(func(a,b): return b.SCORE < a.SCORE)
	for action:ACTION in all_actions:
		if action.can_do_action():
			return ["add", action]

	print("no action found")
	return ["running", null]
