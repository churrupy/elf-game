class_name PickupAction extends ACTION

var TARGET_INVENTORY:INVENTORY
var PICKUP_ITEM:ITEM
# var ITEM_OWNER:Node

func _init(engine, owner:NPC) -> void:
	ID = "pickup"
	ENGINE = engine
	OWNER = owner
	CHATTABLE = false

#region builder
func set_item(_item:ITEM) -> PickupAction:
	PICKUP_ITEM = _item
	return self

func set_inventory(_inventory:INVENTORY) -> PickupAction:
	TARGET_INVENTORY = _inventory
	return self

func find_closest_item_by_tag(tag:String) -> PickupAction:
	var filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().has_tag(tag)
	var filtered_inventories:Array[INVENTORY] = filter.run_filter()
	if len(filtered_inventories) > 0:
		# doesn't take into consideration pathfinding :(
		filtered_inventories.sort_custom(func(a,b): b.OWNER.LOCATION.distance_to(OWNER.LOCATION) < a.OWNER.LOCATION.distance_to(OWNER.LOCATION))
		TARGET_INVENTORY = filtered_inventories[0]
		PICKUP_ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(TARGET.OWNER, tag)
	return self


#endregion builder

func tick() -> ActionResult:
	return run()

func run() -> ActionResult:
	print("PickupAction.run()")
	print("action details:", self)
	if TARGET_INVENTORY == null or PICKUP_ITEM == null:
		return ActionResult.new("end")

	print("checking if item still in target inventory")

	if !ENGINE.InventoryManager.inventory_has_item(TARGET_INVENTORY.OWNER, PICKUP_ITEM):
		return ActionResult.new("end")

	print("PICKING UP")
	
	if OWNER.LOCATION.distance_to(TARGET_INVENTORY.OWNER.LOCATION) > 1.5:
		var new_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(TARGET_INVENTORY.OWNER).calling_action(self)
		return ActionResult.new("add", new_action)
	else:
		ENGINE.InventoryManager.remove_from_inventory(TARGET_INVENTORY.OWNER, PICKUP_ITEM)
		ENGINE.InventoryManager.add_to_inventory(OWNER, PICKUP_ITEM)
		ENGINE.History.create_event(self)
		return ActionResult.new("end")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"picks up",
		PICKUP_ITEM.NAME,
		"from",
		TARGET_INVENTORY.OWNER.NAME
	]
	return " ".join(str_list)
