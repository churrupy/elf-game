class_name PickupAction extends ACTION

# var TARGET_INVENTORY:INVENTORY
# var PICKUP_ITEM:ITEM
# # var ITEM_OWNER:Node

# var ITEM_TAG:String

# var HAS_ITEM:bool = false
# var NEAR_INVENTORY:bool = false
# var INVENTORY_IN_ROOM:bool = false

# func _init(engine, owner:NPC) -> void:
# 	ID = "pickup"
# 	ENGINE = engine
# 	OWNER = owner
# 	CHATTABLE = false

#region builder
# func set_tag(_tag:String) -> PickupAction:
# 	ITEM_TAG = _tag
# 	return self

# func set_item(_item:ITEM) -> PickupAction:
# 	PICKUP_ITEM = _item
# 	return self

# func set_target(_target:Node) -> PickupAction:
# 	TARGET = _target
# 	TARGET_INVENTORY = ENGINE.InventoryManager.get_inventory_of(TARGET.ID)
# 	return self

# func set_inventory(_inventory:INVENTORY) -> PickupAction:
# 	TARGET_INVENTORY = _inventory
# 	return self

# func find_closest_item_by_tag(tag:String) -> PickupAction:
# 	var filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().has_tag(tag)
# 	var filtered_inventories:Array[INVENTORY] = filter.run_filter()
# 	if len(filtered_inventories) > 0:
# 		# doesn't take into consideration pathfinding :(
# 		filtered_inventories.sort_custom(func(a,b): return a.OWNER.LOCATION.distance_to(OWNER.LOCATION) < b.OWNER.LOCATION.distance_to(OWNER.LOCATION))
# 		TARGET_INVENTORY = filtered_inventories[0]
# 		PICKUP_ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(TARGET_INVENTORY.OWNER, tag)
# 	return self


#endregion builder

# func tick() -> ActionResult:
# 	return run()

# func enter_state() -> void:
# 	PICKUP_ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(OWNER, ITEM_TAG)
# 	if PICKUP_ITEM != null:
# 		HAS_ITEM = true
# 	else:		
# 		var inventory_filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().in_range_of(OWNER.LOCATION).has_tag(ITEM_TAG)
# 		var filtered_inventory:Array[INVENTORY] = inventory_filter.run_filter()
# 		if len(filtered_inventory) > 0:
# 			NEAR_INVENTORY = true
# 			TARGET_INVENTORY = filtered_inventory[0]
# 			PICKUP_ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(TARGET_INVENTORY.OWNER, ITEM_TAG)

# 	if !NEAR_INVENTORY:
# 		var inventory_filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().in_range_of(OWNER.LOCATION, 10).has_tag(ITEM_TAG)
# 		var filtered_inventory:Array[INVENTORY] = inventory_filter.run_filter()
# 		if len(filtered_inventory) > 0:
# 			INVENTORY_IN_ROOM = true
# 			filtered_inventory.sort_custom(func(a,b): return a.OWNER.LOCATION.distance_to(OWNER.LOCATION) < b.OWNER.LOCATION.distance_to(OWNER.LOCATION))
# 			TARGET_INVENTORY = filtered_inventory[0]
# 			PICKUP_ITEM = ENGINE.InventoryManager.get_first_tagged_from_inventory(TARGET_INVENTORY.OWNER, ITEM_TAG)

# 	if !INVENTORY_IN_ROOM:
# 		# need to figure out a "goal not possible" logic flow
# 		# at this point the npc would leave the map/room and go to another building or something
# 		# especially important for actions that depend on pickupable items (vs something like bladder, which depends on the avaibility of an object that will always be there)
# 		pass

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



#func run() -> ActionResult:
	#print("entering: PickupAction")
	#if HAS_ITEM:
		#return ActionResult.new("end")
	#elif NEAR_INVENTORY:
		## sEpArAtE yOuR lOgIc FrOm yOuR aCtIoNs
		#PICKUP_ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(TARGET_INVENTORY.OWNER, ITEM_TAG)
		#ENGINE.InventoryManager.add_to_inventory(OWNER, PICKUP_ITEM)
		#ENGINE.History.create_event(self)
		#return ActionResult.new("end")
	#elif INVENTORY_IN_ROOM:
		#var tile_filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().in_range_of(TARGET_INVENTORY.OWNER.LOCATION)
		#var tile_list:Array[TILE] = tile_filter.run_filter()
		#tile_list.sort_custom(func(a,b): return a.LOCATION.distance_to(OWNER.LOCATION) < b.LOCATION.distance_to(OWNER.LOCATION))
		#LOCATION = tile_list[0].LOCATION
		#var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_location(LOCATION).set_goal(self)
		#return ActionResult.new("action", new_action)
	#print("ending pickup action")
	#return ActionResult.new("end")



# func run_old() -> ActionResult:
# 	print("PickupAction.run()")
# 	print("action details:", self)
# 	if TARGET_INVENTORY == null or PICKUP_ITEM == null:
# 		return ActionResult.new("end")

# 	print("checking if item still in target inventory")

# 	if !ENGINE.InventoryManager.inventory_has_item(TARGET_INVENTORY.OWNER, PICKUP_ITEM):
# 		return ActionResult.new("end")

# 	# print("PICKING UP")
	
# 	if OWNER.LOCATION.distance_to(TARGET_INVENTORY.OWNER.LOCATION) > 1.5:
# 		var new_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(TARGET_INVENTORY.OWNER).calling_action(self)
# 		OWNER.GOAL_ACTION.LOCATION = new_action.LOCATION
# 		return ActionResult.new("add", new_action)
# 	else:
# 		ENGINE.InventoryManager.remove_from_inventory(TARGET_INVENTORY.OWNER, PICKUP_ITEM)
# 		ENGINE.InventoryManager.add_to_inventory(OWNER, PICKUP_ITEM)
# 		ENGINE.History.create_event(self)
# 		return ActionResult.new("end")

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
