class_name HungerAction extends ACTION

enum STATUS {
	RUNNING,
	FAILURE,
	SUCCESS
}

func _init(engine, owner: NPC, target:TILE = null) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "snack"
	ENGINE = engine
	OWNER = owner
	TARGET = null
	LOCATION = Vector2.INF
	#super._init(engine, owner, target)

func score() -> void:
	# sets ACTION.LOCATION as well
	SCORE += 10 # hunger bonus for urgent needs
	var hunger: int = OWNER.NEEDS["hunger"]
	SCORE += 100 - hunger

	var is_impassable: bool = ENGINE.Map.is_impassable(TARGET.LOCATION)
	var is_reserved: bool = ENGINE.NpcManager.is_reserved(TARGET.LOCATION)
	if is_impassable or is_reserved:
		if !can_do_off_tile: 
			SCORE = -100
			return
		var closest_location: Vector2 = ENGINE.Map.get_closest_adjacent_location(OWNER.LOCATION, TARGET.LOCATION)
		if closest_location == Vector2.INF:
			# no closest location found
			SCORE = -100
			return
		LOCATION = closest_location
	else:
		LOCATION = TARGET.LOCATION

	SCORE -= OWNER.LOCATION.distance_to(LOCATION)

# func tick() -> ActionResult:
# 	if LOCATION == null:
# 		determine_target_fallback()
# 		return ActionResult.new("running", null)
# 	elif OWNER.LOCATION != LOCATION:
# 		var new_action: MoveAction = MoveAction.new(ENGINE, OWNER, LOCATION, "hunger")
# 		return ActionResult.new("add", new_action)
# 	else:


func tick() -> ActionResult:
	var res: ActionResult = run()
	return res




func run_old() -> ActionResult:
	refresh_needs("hunger")
	#ENGINE.History.add_event(OWNER.ID, "ate", LOCATION)

	#chitchat()

	COUNTDOWN -= 1
	if COUNTDOWN < 0:
		return ActionResult.new("end", null)
		#return ["end", null]
	
	return ActionResult.new("running", null)
	#return ["running", null]


func run() -> ActionResult:
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



func determine_next_action() -> STATUS:
	# fallback
	var node_list: Array[Callable] = [
		eat_food_sequence,
		get_food_action
	]

	for node:Callable in node_list:
		var status = node.call()
		if status != STATUS.FAILURE: return status
	return STATUS.FAILURE



func eat_food_sequence() -> STATUS:
	var node_list: Array[Callable] = [
		has_food_cond,
		eat_food_action
	]

	for node: Callable in node_list:
		var status: STATUS = node.call()
		if status != STATUS.SUCCESS: return status
	return STATUS.SUCCESS


func has_food_cond() -> STATUS:
	var has_food: bool = ENGINE.InventoryManager.inventory_has(OWNER, "food")
	if has_food:
		TARGET = OWNER
		LOCATION = OWNER.LOCATION
		return STATUS.SUCCESS
	return STATUS.FAILURE

func eat_food_action() -> STATUS:
	var inventory: INVENTORY = ENGINE.InventoryManager.get_inventory_of(OWNER.ID)
	var food_item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(OWNER, "food")
	OWNER.consume(food_item)
	ENGINE.InventoryManager.remove_from_inventory(OWNER, food_item)
	food_item.queue_free()
	return STATUS.SUCCESS



func get_food_action() -> STATUS:
	var item_inventories: Array[INVENTORY] = ENGINE.InventoryManager.filter_inventories_by_tag("food")
	if len(item_inventories) == 0:
		# no items in room, npc will have to move out of room to fulfill action
		return STATUS.FAILURE

	var item_locations: Array[Vector2] = ENGINE.InventoryManager.get_inventory_locations(item_inventories)
	print("locations of tag")
	print(item_locations)
	if OWNER.LOCATION in item_locations:
		#item is on floor on OWNER's tile
		pickup_item(OWNER.LOCATION)
		return STATUS.SUCCESS

	var closest_dict: Dictionary = ENGINE.Map.filter_closest_interactable_locations_dict(OWNER.LOCATION, item_locations)
	if OWNER.LOCATION in closest_dict.keys():
		pickup_item(closest_dict[OWNER.LOCATION])
		return STATUS.SUCCESS

	var loc_list: Array = closest_dict.keys()
	loc_list.sort_custom(func(a,b): OWNER.LOCATION.distance_to(b) < OWNER.LOCATION.distance_to(a))

	var target_location: Vector2 = loc_list[0]
	var tile: TILE = ENGINE.Map.get_tile(target_location)
	var new_action: ACTION = MoveAction.new(ENGINE, OWNER, tile, "hunger")
	ENGINE.NpcManager.add_state(new_action)
	return STATUS.RUNNING



func pickup_item(loc: Vector2) -> void:
	var inventory: INVENTORY = ENGINE.InventoryManager.get_inventory_at_location(loc)
	print(inventory)
	var item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(inventory.OWNER, "food")
	ENGINE.InventoryManager.add_to_inventory(OWNER, item)

