class_name ConsumeAction extends ACTION

var FOOD_ITEM:ITEM

func run() -> ActionResult:
	if OWNER.NEEDS["hunger"] >= 50:
		return ActionResult.new("success")

	FOOD_ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(OWNER, "food")
	OWNER.NEEDS["hunger"] += FOOD_ITEM.DATA["nutrition"]

	ENGINE.History.create_event(self)
	return ActionResult.new("success")

	

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"ate",
		str(FOOD_ITEM)
	]
	return " ".join(str_list)