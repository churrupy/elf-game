class_name HungerAction extends ACTION

enum STATUS {
	RUNNING,
	FAILURE,
	SUCCESS
}

func _init(engine, owner: NPC, target:Node) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "snack"
	ENGINE = engine
	OWNER = owner
	TARGET = target
	#LOCATION = Vector2.INF
	CHATTABLE = false
	#super._init(engine, owner, target)



func tick() -> ActionResult:
	var res: ActionResult = run()
	return res



func run() -> ActionResult:

	# if owner has food in inventory
	if ENGINE.InventoryManager.inventory_has(OWNER, "food"):
		var food_item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(OWNER, "food")
		OWNER.consume(food_item)
		ENGINE.InventoryManager.remove_from_inventory(OWNER, food_item)
		food_item.queue_free()
		return ActionResult.new("end")
	
	# if owner is standing close to something that has food in their inventory
	var filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().in_range_of(OWNER.LOCATION).has_tag("food")
	var filtered_inventories:Array[INVENTORY] = filter.run_filter()
	if len(filtered_inventories) > 0:
		var chosen_inventory:INVENTORY = filtered_inventories.pick_random()
		var food_item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(chosen_inventory.OWNER, "food")
		ENGINE.InventoryManager.add_to_inventory(OWNER, food_item)
		return ActionResult.new("running")

	# if owner is in the same room as something that has food in their inventory
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	filter = INVENTORY_FILTER.new(ENGINE).set_list().is_in_room(current_room).has_tag("food")
	filtered_inventories = filter.run_filter()
	if len(filtered_inventories) > 0:
		var chosen_inventory:INVENTORY = filtered_inventories.pick_random()
		var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(chosen_inventory.OWNER).calling_action(self)
		return ActionResult.new("add", move_action)

	var new_action:LeaveRoomAction = LeaveRoomAction.new(ENGINE, OWNER).set_location().calling_action(self)
	return ActionResult.new("add", new_action)



func pickup_item(loc: Vector2) -> void:
	print("picking up")
	var inventory: INVENTORY = ENGINE.InventoryManager.get_inventory_at_location(loc)
	#print(inventory)
	var item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(inventory.OWNER, "food")
	print(item)
	ENGINE.InventoryManager.add_to_inventory(OWNER, item)
	print("inventory: ", ENGINE.InventoryManager.get_inventory_of(OWNER.ID))
