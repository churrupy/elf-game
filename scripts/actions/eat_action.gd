class_name EatAction extends ACTION

var FOOD_ITEM:ITEM

func _init(engine, owner:NPC) -> void:
	ENGINE = engine
	OWNER = owner
	ID = "eat"

func set_item(_food:ITEM) -> EatAction:
	FOOD_ITEM = _food
	return self

func run() -> ActionResult:
	if !ENGINE.InventoryManager.inventory_has_item(OWNER, FOOD_ITEM):
		return ActionResult.new("end")
	
	# OWNER.consume(FOOD_ITEM)
	OWNER.NEEDS["hunger"] += FOOD_ITEM.DATA["nutrition"]
	ENGINE.InventoryManager.remove_from_inventory(OWNER, FOOD_ITEM)
	ENGINE.History.create_event(self)
	return ActionResult.new("end")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"eats"
	]
	return " ".join(str_list)
