class_name HungerGoal extends ACTION



func score() -> HungerGoal:
	# if food in inventory, return 0
	if ENGINE.InventoryManager.inventory_has_tag(OWNER, "food"):
		SCORE = 0.0
		return self
	
	var need:float = OWNER.NEEDS["hunger"]/100
	SCORE = 1 - (need * need)
	return self

func run() -> ActionResult:
	if ENGINE.InventoryManager.inventory_has_tag(OWNER, "food"):
		STATUS = "success"
		return ActionResult.new("end")

	if CURRENT_ACTION == null:
		OWNER.BLACKBOARD["target_need"] = "hunger"
		set_current_action(PickupItemGoal)
		return ActionResult.new("continue")

	if CURRENT_ACTION.STATUS != "running":
		STATUS = CURRENT_ACTION.STATUS
		return ActionResult.new("end")
	
	return ActionResult.new("continue")


func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is trying to refresh hunger"
	]
	return " ".join(str_list)
