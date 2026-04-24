class_name INVENTORY_MANAGER extends Object

var INVENTORIES: Dictionary[String, INVENTORY]
var ENGINE


func add_inventory(owner:Node) -> void:
	if owner.ID not in INVENTORIES:
		var new_inventory:INVENTORY = INVENTORY.new(owner)
		INVENTORIES[owner.ID] = new_inventory

func add_to_inventory(owner: Node, item: ITEM) -> void:
	var owner_inventory: INVENTORY = INVENTORIES[owner.ID]
	owner_inventory.ITEMS.append(item)

func remove_from_inventory(owner:Node, item:ITEM) -> void:
	var owner_inventory:INVENTORY = INVENTORIES[owner.ID]
	var index: int = owner_inventory.find(item)
	if index > -1:
		owner_inventory.remove_at(index)


func inventory_has(owner_id:String, tag:String) -> bool:
	var inventory: INVENTORY = INVENTORIES[owner_id]
	for item: ITEM in inventory.ITEMS:
		if tag in item:
			return true

	return false

func filter_inventories_by_tag(tag:String) -> Array[INVENTORY]:
	var filtered_list: Array[INVENTORY]
	for id:String in INVENTORIES.keys():
		if inventory_has(id, tag):
			var inventory: INVENTORY = INVENTORIES[id]
			filtered_list.append(inventory)
	return filtered_list
	
