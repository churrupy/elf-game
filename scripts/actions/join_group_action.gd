class_name JoinGroupAction extends ACTION


func _init(engine, owner:NPC, target:NPC) -> void:
	ID = "join_group"
	LOCATION = target.LOCATION
	ENGINE = engine
	OWNER = owner
	TARGET = target
	CHATTABLE = false
	#super._init(engine, owner, target)


func tick() -> ActionResult:
	var result: ActionResult = run()
	OWNER.decay_needs()
	return result

func run() -> ActionResult:
	# check if target is still available
	var target_action:ACTION = TARGET.STATE_STACK[-1]
	if !target_action.CHATTABLE:
		print("npc now unavailable")
		return ActionResult.new("end")
	# var available_npcs:Array[NPC] = ENGINE.NpcManager.filter_available_npcs([TARGET])
	# if len(available_npcs) == 0:
	# 	print("npc now unavailable")
	# 	return ActionResult.new("end")

	if OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
		#print("moving to npc")
		var move_action: MoveAction = MoveAction.new(ENGINE, OWNER, TARGET, self)
		move_action.LOCATION = LOCATION
		return ActionResult.new("add", move_action)
	else:
		ENGINE.GroupManager.join_npc(OWNER, TARGET)
		return ActionResult.new("end")
