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




# func run_old() -> ActionResult:
# 	refresh_needs("hunger")
# 	#ENGINE.History.add_event(OWNER.ID, "ate", LOCATION)

# 	#chitchat()

# 	COUNTDOWN -= 1
# 	if COUNTDOWN < 0:
# 		return ActionResult.new("end", null)
# 		#return ["end", null]
	
# 	return ActionResult.new("running", null)
# 	#return ["running", null]

func run() -> ActionResult:

	if ENGINE.InventoryManager.inventory_has(OWNER, "food"):
		var food_item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(OWNER, "food")
		OWNER.consume(food_item)
		ENGINE.InventoryManager.remove_from_inventory(OWNER, food_item)
		food_item.queue_free()
		return ActionResult.new("end")
	
	var filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().in_range_of(OWNER.LOCATION).has_tag("food")
	var filtered_inventories:Array[INVENTORY] = filter.run_filter()
	if len(filtered_inventories) > 0:
		var chosen_inventory:INVENTORY = filtered_inventories.pick_random()
		var food_item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(chosen_inventory.OWNER, "food")
		ENGINE.InventoryManager.add_to_inventory(OWNER, food_item)
		return ActionResult.new("running")

	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	filter = INVENTORY_FILTER.new(ENGINE).set_list().is_in_room(current_room).has_tag("food")
	filtered_inventories = filter.run_filter()
	if len(filtered_inventories) > 0:
		var chosen_inventory:INVENTORY = filtered_inventories.pick_random()
		var move_action:MoveAction = MoveAction.new(ENGINE, OWNER, chosen_inventory.OWNER, self).set_location()
		return ActionResult.new("add", move_action)

	print("no valid eating actions")
	print("need to figure out how to check this and move on to the next option if possible")
	return ActionResult.new("clear")

func run_old() -> ActionResult:
	var action_status: STATUS = determine_next_action()
	if action_status == STATUS.SUCCESS:
		return ActionResult.new("end", null)
	elif action_status == STATUS.RUNNING:
		return ActionResult.new("running", null)
	else:
		# STATUS.FAILURE
		# this is when options to eat are not on the map, but no one can leave the map yet so whatever
		return ActionResult.new("running", null)


# func determine_target_fallback() -> STATUS:
# 	var node_list: Array[Callable] = [
# 		has_food_in_inventory_cond,
# 		get_food_sequence
# 	]

# 	for node:Callable in node_list:
# 		var status = node.call()
# 		if status != STATUS.FAILURE: return status
# 	return STATUS.FAILURE



# func determine_next_action_old() -> STATUS:
# 	# fallback
# 	var node_list: Array[Callable] = [
# 		eat_food_sequence,
# 		get_food_action
# 	]

# 	for node:Callable in node_list:
# 		var status = node.call()
# 		if status != STATUS.FAILURE: return status
# 	return STATUS.FAILURE


func determine_next_action() -> STATUS:
	# sequence
	var node_list:Array[Callable] = [
		get_food,
		eat_food,
	]

	for node:Callable in node_list:
		var status:STATUS = node.call()
		if status != STATUS.SUCCESS: return status
	return STATUS.SUCCESS

func get_food() -> STATUS:
	if OWNER == TARGET:
		LOCATION = OWNER.LOCATION
		CHATTABLE = true
		return STATUS.SUCCESS

	elif OWNER.LOCATION == LOCATION:
		pickup_item(TARGET.LOCATION)
		return STATUS.RUNNING

	else:
		var new_action: MoveAction = MoveAction.new(ENGINE, OWNER, TARGET, self).set_location()
		# moveaction determines target location
		# takes into consideration whether npc should be on tile, or adjacent to tile
		LOCATION = new_action.LOCATION
		#new_action.LOCATION = LOCATION
		ENGINE.NpcManager.add_state(new_action)
		return STATUS.RUNNING


# func get_food() -> STATUS:
# 	var has_food: bool = ENGINE.InventoryManager.inventory_has(OWNER, "food")
# 	if has_food:
# 		TARGET = OWNER #keep them in place? probably don't need this any more lol
# 		LOCATION = OWNER.LOCATION
# 		CHATTABLE = true
# 		return STATUS.SUCCESS
# 	#return STATUS.FAILURE

# 	var item_inventories: Array[INVENTORY] = ENGINE.InventoryManager.filter_inventories_by_tag("food")
# 	if len(item_inventories) == 0:
# 		# no items in room, npc will have to move out of room to fulfill action
# 		return STATUS.FAILURE

# 	var item_locations: Array[Vector2] = ENGINE.InventoryManager.get_inventory_locations(item_inventories)
# 	#print("locations of tag")
# 	#print(item_locations)
# 	if OWNER.LOCATION in item_locations:
# 		#item is on floor on OWNER's tile
# 		pickup_item(OWNER.LOCATION)
# 		return STATUS.RUNNING #so they don't pickup and eat on the same tick

# 	var closest_dict: Dictionary = ENGINE.Map.filter_closest_interactable_locations_dict(OWNER.LOCATION, item_locations)
# 	if OWNER.LOCATION in closest_dict.keys():
# 		pickup_item(closest_dict[OWNER.LOCATION])
# 		return STATUS.RUNNING #so they don't pickup and eat on the same tick

# 	var loc_list: Array = closest_dict.keys()
# 	loc_list.sort_custom(func(a,b): OWNER.LOCATION.distance_to(b) < OWNER.LOCATION.distance_to(a))

# 	var target_location: Vector2 = loc_list[0]
# 	var tile: TILE = ENGINE.Map.get_tile(target_location)
# 	var new_action: ACTION = MoveAction.new(ENGINE, OWNER, tile, self)
# 	ENGINE.NpcManager.add_state(new_action)
# 	return STATUS.RUNNING

func eat_food() -> STATUS:
	var inventory: INVENTORY = ENGINE.InventoryManager.get_inventory_of(OWNER.ID)
	var food_item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(OWNER, "food")
	OWNER.consume(food_item)
	ENGINE.InventoryManager.remove_from_inventory(OWNER, food_item)
	food_item.queue_free()
	return STATUS.SUCCESS


func pickup_item(loc: Vector2) -> void:
	print("picking up")
	var inventory: INVENTORY = ENGINE.InventoryManager.get_inventory_at_location(loc)
	#print(inventory)
	var item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(inventory.OWNER, "food")
	print(item)
	ENGINE.InventoryManager.add_to_inventory(OWNER, item)
	print("inventory: ", ENGINE.InventoryManager.get_inventory_of(OWNER.ID))




# func eat_food_sequence() -> STATUS:
# 	var node_list: Array[Callable] = [
# 		get_food,
# 		eat_food
# 	]

# 	for node:Callable in node_list:
# 		var status:STATUS = node.call()
# 		if status != STATUS.SUCCESS: return status
# 	return STATUS.SUCCESS


# func has_food_cond() -> STATUS:
# 	var has_food: bool = ENGINE.InventoryManager.inventory_has(OWNER, "food")
# 	if has_food:
# 		TARGET = OWNER
# 		LOCATION = OWNER.LOCATION
# 		return STATUS.SUCCESS
# 	return STATUS.FAILURE

# func eat_food_action() -> STATUS:
# 	var inventory: INVENTORY = ENGINE.InventoryManager.get_inventory_of(OWNER.ID)
# 	var food_item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(OWNER, "food")
# 	OWNER.consume(food_item)
# 	ENGINE.InventoryManager.remove_from_inventory(OWNER, food_item)
# 	food_item.queue_free()
# 	return STATUS.SUCCESS



# func get_food_action() -> STATUS:
# 	var item_inventories: Array[INVENTORY] = ENGINE.InventoryManager.filter_inventories_by_tag("food")
# 	if len(item_inventories) == 0:
# 		# no items in room, npc will have to move out of room to fulfill action
# 		return STATUS.FAILURE

# 	var item_locations: Array[Vector2] = ENGINE.InventoryManager.get_inventory_locations(item_inventories)
# 	#print("locations of tag")
# 	#print(item_locations)
# 	if OWNER.LOCATION in item_locations:
# 		#item is on floor on OWNER's tile
# 		pickup_item(OWNER.LOCATION)
# 		return STATUS.SUCCESS

# 	var closest_dict: Dictionary = ENGINE.Map.filter_closest_interactable_locations_dict(OWNER.LOCATION, item_locations)
# 	if OWNER.LOCATION in closest_dict.keys():
# 		pickup_item(closest_dict[OWNER.LOCATION])
# 		return STATUS.SUCCESS

# 	var loc_list: Array = closest_dict.keys()
# 	loc_list.sort_custom(func(a,b): OWNER.LOCATION.distance_to(b) < OWNER.LOCATION.distance_to(a))

# 	var target_location: Vector2 = loc_list[0]
# 	var tile: TILE = ENGINE.Map.get_tile(target_location)
# 	var new_action: ACTION = MoveAction.new(ENGINE, OWNER, tile, self)
# 	ENGINE.NpcManager.add_state(new_action)
# 	return STATUS.RUNNING
