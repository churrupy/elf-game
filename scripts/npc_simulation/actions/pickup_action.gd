class_name PickupAction extends ACTION

func set_id() -> void:
	ID = "PickupAction"

func end_action() -> void:
	OWNER.BLACKBOARD["target_tile"] = null
	OWNER.BLACKBOARD["target_item"] = null

func run() -> ActionResult:
	if "target_tile" not in OWNER.BLACKBOARD or "target_item" not in OWNER.BLACKBOARD:
		return ActionResult.new("fail")

	print("Picking up item")
	var target_tile:TILE = OWNER.BLACKBOARD["target_tile"]
	var target_item:ITEM = OWNER.BLACKBOARD["target_item"]

	if !target_tile.in_range(OWNER.LOCATION):
		print("owner is too far away from inventory")
		return ActionResult.new("fail")

	ENGINE.InventoryManager.remove_from_inventory(target_tile, target_item)
	ENGINE.InventoryManager.add_to_inventory(OWNER, target_item)

	ENGINE.History.add_event(self)
	return ActionResult.new("success")




func _to_string() -> String:
	var target_item:ITEM = OWNER.BLACKBOARD["target_item"]
	var target_tile:TILE = OWNER.BLACKBOARD["target_tile"]
	var str_list:Array[String] = [
		OWNER.NAME,
		"picks up",
		str(target_item),
		"from",
		str(target_tile)
	]
	return " ".join(str_list)
