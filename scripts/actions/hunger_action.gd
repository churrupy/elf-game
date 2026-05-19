class_name HungerAction extends ACTION



var FOOD_ITEM:ITEM

var FULL_HUNGER:bool = false
var HAS_FOOD:bool = false

var IMPOSSIBLE:bool = false

func _init(engine, owner: NPC) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "snack"
	ENGINE = engine
	OWNER = owner
	# TARGET = target
	#LOCATION = Vector2.INF
	CHATTABLE = false
	#super._init(engine, owner, target)

# func validate() -> bool:
# 	LOCATION = OWNER.LOCATION
# 	FOOD_ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(OWNER, "food")
# 	if FOOD_ITEM == null:
# 		var filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().has_tag("food")
# 		var filtered_inventories:Array[INVENTORY] = filter.run_filter()
# 		if len(filtered_inventories) > 0:
# 			filtered_inventories.sort_custom(func(a,b): b.OWNER.LOCATION.distance_to(OWNER.LOCATION) < a.OWNER.LOCATION.distance_to(OWNER.LOCATION))
# 			var chosen_inventory:INVENTORY = filtered_inventories[0]
# 			TARGET = chosen_inventory.OWNER
# 			FOOD_ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(TARGET, "food")
# 	else:
# 		TARGET = OWNER
	
# 	if FOOD_ITEM == null:
# 		VALID = false
# 		return false
# 	return true

# func get_next_action() -> ActionResult:
# 	FOOD_ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(OWNER, "food")
# 	if FOOD_ITEM == null:
# 		var new_goal:ACTION = PickupAction.new(ENGINE, OWNER).find_closest_by_tag("food")
# 		FOOD_ITEM = new_goal.PICKUP_ITEM
# 		return ActionResult.new("add", new_goal)
# 	return ActionResult.new("running")

# func tick() -> ActionResult:
# 	var res: ActionResult = run()
# 	return res

# func run_new() -> ActionResult:
# 	var res:ActionResult.new("replace")

	# if food not in hand:
		# add HoldAction to action_stack
		# if item not in inventory:
			# add PickUpAction to action_stack
			# if item not nearby:
				# add MoveAction to action_stack

	# how to figure out item through all that? idk, i wanna play games

func enter_state() -> void:
	print("entering: HungerAction")
	if OWNER.NEEDS["hunger"] >= 80:
		FULL_HUNGER = true
		return
	
	HAS_FOOD = ENGINE.InventoryManager.inventory_has_tag(OWNER, "food")

func run() -> ActionResult:
	if FULL_HUNGER:
		return ActionResult.new("end")
	
	elif HAS_FOOD:
		# naughty, bad programmer, slap!
		print("food in inventory")
		var food_item:ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(OWNER, "food")
		var new_action:ACTION = EatAction.new(ENGINE, OWNER).set_item(food_item)
		return ActionResult.new("action",  new_action)
		# OWNER.consume(food_item)
		# ENGINE.InventoryManager.remove_from_inventory(OWNER, food_item)
		# ENGINE.History.create_event(self)
		# food_item.queue_free()
		# return ActionResult.new("end")

	else:
		var new_action:ACTION = PickupAction.new(ENGINE, OWNER).set_tag("food")
		return ActionResult.new("add", new_action)


# func run() -> ActionResult:

# 	if OWNER.NEEDS["hunger"] >= 80:
# 		return ActionResult.new("end").continuing()

# 	# how to return because of no food available? 

# 	# if owner has food in inventory
# 	if ENGINE.InventoryManager.inventory_has_tag(OWNER, "food"):
# 		print("food in inventory")
# 		var food_item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(OWNER, "food")
# 		OWNER.consume(food_item)
# 		ENGINE.InventoryManager.remove_from_inventory(OWNER, food_item)
# 		ENGINE.History.create_event(self)
# 		# food_item.queue_free()
# 		return ActionResult.new("end")

# 	else:
# 		var filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().has_tag("food")
# 		var filtered_inventories:Array[INVENTORY] = filter.run_filter()
# 		if len(filtered_inventories) > 0:
# 			filtered_inventories.sort_custom(func(a,b): b.OWNER.LOCATION.distance_to(OWNER.LOCATION) < a.OWNER.LOCATION.distance_to(OWNER.LOCATION))
# 			var chosen_inventory:INVENTORY = filtered_inventories[0]
# 			var chosen_item:ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(chosen_inventory.OWNER, "food")

# 			var new_action:PickupAction = PickupAction.new(ENGINE, OWNER).set_inventory(chosen_inventory).set_item(chosen_item)
# 			return ActionResult.new("add", new_action).continuing()
# 		else:
# 			return ActionResult.new("end").continuing()
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

# func populate_stack() -> void:
# 	print("Goal: Hunger Action")
# 	var new_action:ACTION = EatAction.new(ENGINE, OWNER).set_item(FOOD_ITEM)
# 	OWNER.STATE_STACK.append(new_action)

# 	if !ENGINE.InventoryManager.inventory_has_item(OWNER, FOOD_ITEM):
# 		new_action = PickupAction.new(ENGINE, OWNER).set_target(TARGET).set_item(FOOD_ITEM)
# 		OWNER.STATE_STACK.append(new_action)

# func populate_stack() -> void:
# 	print("Goal: Hunger Action")
# 	LOCATION = OWNER.LOCATION
# 	var new_action:ACTION
# 	var food_item:ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(OWNER, "food")
# 	if food_item == null:
# 		new_action = PickupAction.new(ENGINE, OWNER).find_closest_item_by_tag("food")
# 		OWNER.STATE_STACK.append(new_action)
# 		food_item = new_action.PICKUP_ITEM
	
# 	new_action = EatAction.new(ENGINE, OWNER).set_item(food_item)
# 	OWNER.STATE_STACK.push_front(new_action)

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"eats"
	]
	return " ".join(str_list)
