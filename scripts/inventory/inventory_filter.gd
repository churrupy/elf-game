class_name INVENTORY_FILTER extends RefCounted

var ENGINE

var inventory_list:Array[INVENTORY]
var is_not_list:Array[INVENTORY] = []
var owner_list:Array[Node] = []
var filtered_list:Array[INVENTORY]

var origin:Vector2 = Vector2.INF
var distance:float
var location:Vector2 = Vector2.INF

var tags:Array[String]
var target_room:ROOM

var check_npcs:bool = false

var fulfills_need:String = ""

func _init(engine) -> void:
	ENGINE = engine

func set_list(_inventory_list:Array[INVENTORY] = []) -> INVENTORY_FILTER:
	if _inventory_list == []:
		inventory_list = ENGINE.InventoryManager.INVENTORIES
	else:
		inventory_list = _inventory_list
	return self

func in_range_of(_origin:Vector2, _distance:float=1.5) -> INVENTORY_FILTER:
	origin=_origin
	distance=_distance
	return self

func set_room(_room:ROOM) -> INVENTORY_FILTER:
	target_room = _room
	return self

func has_tag(_tag:String) -> INVENTORY_FILTER:
	tags.append(_tag)
	return self

func set_location(loc:Vector2) -> INVENTORY_FILTER:
	location = loc
	return self

func is_not(inventory:INVENTORY) -> INVENTORY_FILTER:
	is_not_list.append(inventory)
	return self

func include_npcs() -> INVENTORY_FILTER:
	check_npcs = true
	return self

func include_owner(owner:Node) -> INVENTORY_FILTER:
	owner_list.append(owner)
	return self

func set_fulfills_need(_need:String) -> INVENTORY_FILTER:
	fulfills_need = _need
	return self


func run_filter() -> Array[INVENTORY]:
	for inventory:INVENTORY in inventory_list:
		if inventory in is_not_list:continue

		if inventory.OWNER in owner_list:
			pass
		else:

			if !check_npcs:
				if inventory.OWNER is NPC: continue

			if location != Vector2.INF:	
				if inventory.OWNER.LOCATION != location: continue

			if origin != Vector2.INF:
				if origin.distance_to(inventory.OWNER.LOCATION) > distance:
					continue

		if fulfills_need != "":
			if !inventory.can_refresh(fulfills_need): continue

		if target_room != null:
			if !target_room.is_in_room(inventory.OWNER.LOCATION): continue

		
		if len(tags) > 0:
			if !is_subset_of(tags, inventory.get_all_tags()): continue


		filtered_list.append(inventory)

	return filtered_list

func convert_to_actions(_npc:NPC) -> Array[ACTION]:
	# converts to PickupItemAction
	var action_list:Array[ACTION]
	var checked_needs:Array[String]
	for i:INVENTORY in filtered_list:
		var needs_list:Array[String] = i.get_all_needs()
		for n:String in needs_list:
			if n not in checked_needs:
				var new_goal:ACTION = PickupItemGoal.new(ENGINE, _npc, null).set_need(n)
				action_list.append(new_goal)
				checked_needs.append(n)
	return action_list



func is_subset_of(subset:Array, parent_set:Array) -> bool:
	for i in subset:
		if i in parent_set: continue
		else: return false

	return true
