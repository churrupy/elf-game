class_name HungerAction extends ACTION

enum STATUS {
	RUNNING,
	FAILURE,
	SUCCESS
}

func _init(engine, owner: NPC) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "snack"
	ENGINE = engine
	OWNER = owner
	# TARGET = target
	#LOCATION = Vector2.INF
	CHATTABLE = true
	#super._init(engine, owner, target)



func tick() -> ActionResult:
	var res: ActionResult = run()
	return res

# func run_new() -> ActionResult:
# 	var res:ActionResult.new("replace")

	# if food not in hand:
		# add HoldAction to action_stack
		# if item not in inventory:
			# add PickUpAction to action_stack
			# if item not nearby:
				# add MoveAction to action_stack

	# how to figure out item through all that? idk, i wanna play games


func run() -> ActionResult:

	if OWNER.NEEDS["hunger"] >= 80:
		return ActionResult.new("end").continuing()

	# how to return because of no food available? 

	# if owner has food in inventory
	if ENGINE.InventoryManager.inventory_has_tag(OWNER, "food"):
		print("food in inventory")
		var food_item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(OWNER, "food")
		OWNER.consume(food_item)
		ENGINE.InventoryManager.remove_from_inventory(OWNER, food_item)
		ENGINE.History.create_event(self)
		# food_item.queue_free()
		return ActionResult.new("end")

	else:
		var filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().has_tag("food")
		var filtered_inventories:Array[INVENTORY] = filter.run_filter()
		if len(filtered_inventories) > 0:
			filtered_inventories.sort_custom(func(a,b): b.OWNER.LOCATION.distance_to(OWNER.LOCATION) < a.OWNER.LOCATION.distance_to(OWNER.LOCATION))
			var chosen_inventory:INVENTORY = filtered_inventories[0]
			var chosen_item:ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(chosen_inventory.OWNER, "food")

			var new_action:PickupAction = PickupAction.new(ENGINE, OWNER).set_inventory(chosen_inventory).set_item(chosen_item)
			return ActionResult.new("add", new_action).continuing()
		else:
			return ActionResult.new("end").continuing()
		# var new_action:PickUpAction = PickUpAction.new(ENGINE, OWNER).find_item_by_tag("food")
		# return ActionResult.new("add", new_action)
	
	# if owner is standing close to something that has food in their inventory
	# var filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().in_range_of(OWNER.LOCATION).has_tag("food")
	# var filtered_inventories:Array[INVENTORY] = filter.run_filter()
	# if len(filtered_inventories) > 0:
	# 	var chosen_inventory:INVENTORY = filtered_inventories.pick_random()
	# 	var food_item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(chosen_inventory.OWNER, "food")
	# 	ENGINE.InventoryManager.add_to_inventory(OWNER, food_item)
	# 	return ActionResult.new("running")

	# # if owner is in the same room as something that has food in their inventory
	# var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	# filter = INVENTORY_FILTER.new(ENGINE).set_list().is_in_room(current_room).has_tag("food")
	# filtered_inventories = filter.run_filter()
	# if len(filtered_inventories) > 0:
	# 	var chosen_inventory:INVENTORY = filtered_inventories.pick_random()
	# 	var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(chosen_inventory.OWNER).calling_action(self)
	# 	return ActionResult.new("add", move_action)

	# var new_action:LeaveRoomAction = LeaveRoomAction.new(ENGINE, OWNER).set_location().calling_action(self)
	# return ActionResult.new("add", new_action)



# func pickup_item(loc: Vector2) -> void:
# 	print("picking up")
# 	var inventory: INVENTORY = ENGINE.InventoryManager.get_inventory_at_location(loc)
# 	#print(inventory)
# 	var item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(inventory.OWNER, "food")
# 	print(item)
# 	ENGINE.InventoryManager.add_to_inventory(OWNER, item)
# 	print("inventory: ", ENGINE.InventoryManager.get_inventory_of(OWNER.ID))

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"eats"
	]
	return " ".join(str_list)
