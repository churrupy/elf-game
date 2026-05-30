class_name JoinNpcAction extends ACTION

# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner

func run() -> ActionResult:
	if "target_npc" not in OWNER.BLACKBOARD:
		return ActionResult.new("fail")
	
	var target_npc:NPC = OWNER.BLACKBOARD["target_npc"]
	if target_npc == null:
		return ActionResult.new("fail")
	
	if !target_npc.is_available():
		return ActionResult.new("fail")

	if ENGINE.GroupManager.is_in_same_group(OWNER, target_npc):
		return ActionResult.new("success")

	if OWNER.LOCATION.distance_to(target_npc.LOCATION) > 1.5:
		#var new_action:ACTION = MoveToTargetAction.new(ENGINE, OWNER)
		add_action(MoveToTargetAction)
		return ActionResult.new("continue")

	ENGINE.GroupManager.join_npc(OWNER, target_npc)
	return ActionResult.new("success")

func _to_string() -> String:
	var target_npc:NPC = OWNER.BLACKBOARD["target_npc"]
	var str_list:Array[String] = [
		OWNER.NAME,
		"is joining",
		target_npc.NAME
	]
	return " ".join(str_list)
