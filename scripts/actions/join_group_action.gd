class_name JoinGroupAction extends ACTION


func _init(engine, owner:NPC) -> void:
	ID = "join_group"
	# LOCATION = target.LOCATION
	ENGINE = engine
	OWNER = owner
	# TARGET = target
	CHATTABLE = false

#region builder
func set_target(target:NPC) -> JoinGroupAction:
	TARGET = target
	LOCATION = target.LOCATION
	return self

#endregion builder

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

	if OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
		var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(TARGET).calling_action(self)
		return ActionResult.new("add", move_action)
	else:
		ENGINE.GroupManager.join_npc(OWNER, TARGET)
		ENGINE.History.create_event(self)
		return ActionResult.new("end")


func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is joining the group of",
		TARGET.NAME,
	]
	return " ".join(str_list)

func get_involved_npcs() -> Array[NPC]:
	var npc_list:Array[NPC] = ENGINE.GroupManager.get_group_participants(OWNER)
	return npc_list

# func is_equal(_event:EVENT_new) -> bool:
# 	return false # not an ongoing event, no need to extend timestamps

# func get_role(npc:NPC) -> String:
# 	if npc == OWNER:
# 		return "participant"
# 	else:
# 		return "witness"
