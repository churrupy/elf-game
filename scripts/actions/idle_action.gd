class_name IdleAction extends ACTION

# this class does determine_action
var Determinator: ActionDeterminator

func _init(engine, owner: NPC, target: Node, determinator: ActionDeterminator) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "idle"
	LOCATION = owner.LOCATION
	Determinator = determinator
	super._init(engine, owner, target)

func resume_state():
	pass
	#var result: ActionResult = run()
	#ENGINE.NpcManager.add_state(result.NEW_ACTION)

func can_do_action() -> bool:
	return true

func tick() -> ActionResult:
	LOCATION = OWNER.LOCATION
	var result:ActionResult = run()
	OWNER.decay_needs()
	return result

func run() -> ActionResult:
	print("running")
	Determinator.determine_next_action(OWNER)
	return ActionResult.new("running", null)


func run_old() -> ActionResult:
	print("running")
	#var dialogue_string: String = OWNER.NAME + " is choosing a new action."
	#ENGINE.History.add_event(OWNER.ID, "converse", OWNER.LOCATION, [], dialogue_string)
	#LOCATION = OWNER.LOCATION # keeps in place for idling
	var all_actions: Array[ACTION] = ENGINE.Map.get_all_actions_on_map(OWNER)
	all_actions += ENGINE.NpcManager.get_all_npc_actions(OWNER)
	all_actions.sort_custom(func(a,b): return b.SCORE < a.SCORE)
	for action:ACTION in all_actions:
		if action.can_do_action():
			return ActionResult.new("add", action)
			#return ["add", action]

	print("no action found")
	return ActionResult.new("running", null)
	#return ["running", null]
