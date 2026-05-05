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

func is_in_room(_room:ROOM) -> INVENTORY_FILTER:
	target_room = _room
	return self

func has_tag(_tag:String) -> INVENTORY_FILTER:
	tags.append(_tag)
	return self

func at_location(loc:Vector2) -> INVENTORY_FILTER:
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

		if target_room != null:
			var inv_room:ROOM = ENGINE.Map.get_room(inventory.OWNER.LOCATION)
			if inv_room != target_room: continue
		
		if len(tags) > 0:
			var matched:bool = false
			for tag:String in tags:
				for item:ITEM in inventory.ITEMS:
					if tag in item.TAGS:
						matched = true
						break
				if matched:
					break
			if !matched: continue

		filtered_list.append(inventory)

	return filtered_list
