class_name INVENTORY_MANAGER extends Object

# var INVENTORIES: Dictionary[String, INVENTORY]
var INVENTORIES: Array[INVENTORY]
var ENGINE


func _init(engine) -> void:
	ENGINE = engine

#region init
func create_inventory(owner:Node) -> void:
	var inventory: INVENTORY = get_inventory_of(owner.ID)
	if inventory == null:
		var new_inventory:INVENTORY = INVENTORY.new(owner)
		INVENTORIES.append(new_inventory)
		#INVENTORIES[owner.ID] = new_inventory

func remove_inventory(owner:Node) -> void:
	# removes inventory of floor tiles after furniture is put on them
	# what a silly way to do this lol
	var inventory: INVENTORY = get_inventory_of(owner.ID)
	var index:int = INVENTORIES.find(inventory)
	if index > -1:
		INVENTORIES.remove_at(index)

#endregion init

func get_inventory_of(id:String) -> INVENTORY:
	for inventory:INVENTORY in INVENTORIES:
		if inventory.OWNER.ID == id: return inventory
	return null

func add_to_inventory(owner: Node, item: ITEM) -> void:
	print("adding", item, "to", owner.NAME, "'s inventory")
	var inventory: INVENTORY = get_inventory_of(owner.ID)
	inventory.ITEMS.append(item)

func remove_from_inventory(owner:Node, item:ITEM) -> void:
	var inventory: INVENTORY = get_inventory_of(owner.ID)
	#var owner_inventory:INVENTORY = INVENTORIES[owner.ID]
	var index: int = inventory.ITEMS.find(item)
	if index > -1:
		inventory.ITEMS.remove_at(index)

func pop_inventory_first_tagged(owner:Node, tag:String) -> ITEM:
	var inventory: INVENTORY = get_inventory_of(owner.ID)
	var chosen_item: ITEM = get_first_tagged_from_inventory(owner, tag)
	if chosen_item == null:
		print("CRASH!")
	remove_from_inventory(owner, chosen_item)
	return chosen_item


func get_first_tagged_from_inventory(owner:Node, tag:String) -> ITEM:
	var inventory:INVENTORY = get_inventory_of(owner.ID)
	for item: ITEM in inventory.ITEMS:
		if tag in item.TAGS:
			return item
	return null


func inventory_has(owner:Node, tag:String) -> bool:
	var inventory = get_inventory_of(owner.ID)
	print(inventory)
	print(inventory.ITEMS)
	for item: ITEM in inventory.ITEMS:
		print(item)
		if tag in item.TAGS:
			return true
	return false










#region tile/furniture
# functions here look at immobile inventories ONLY
# NO NPC INVENTORIES
func get_inventory_at_location(loc:Vector2) -> INVENTORY:
	var inventory_list: Array[INVENTORY] # cause it'll return both the item and the tile as inventory options
	for inventory: INVENTORY in INVENTORIES:
		if inventory.OWNER is NPC: continue # skip mobile inventories
		if inventory.OWNER.LOCATION == loc:
			inventory_list.append(inventory)
	if len(inventory_list) == 0:
		# this should never happen so long as location is valid
		push_error("No inventory found at ", ENGINE.prettify_vector(loc))
		return null
	elif len(inventory_list) == 1:
		return inventory_list[0]
	else:
		# multiple 
		# also shouldn't happen but i'm less confident in it
		print(inventory_list)
		push_error("Multiple inventories at ", ENGINE.prettify_vector(loc))
		return null


func filter_inventories_by_tag(tag:String) -> Array[INVENTORY]:
	# doesn't check npc inventories because that's pickpocketing
	# i'll figure out how I want to properly deal with this later
	var return_list: Array[INVENTORY]
	for inventory:INVENTORY in INVENTORIES:
		if inventory.OWNER is NPC: continue
		var tag_list: Array[String] = inventory.get_all_tags()
		if tag in tag_list:
			return_list.append(inventory)
	return return_list


func filter_locations_by_tag(tag:String, loc_list:Array[Vector2] = get_inventory_locations()) -> Array[Vector2]:
	# only returns tile/furniture inventory locations
	var return_list: Array[Vector2]
	for loc:Vector2 in loc_list:
		var inventory: INVENTORY = get_inventory_at_location(loc)
		var tags: Array[String] = inventory.get_all_tags()
		if tag in tags:
			return_list.append(loc)
	return return_list


func get_inventory_locations(inv_list:Array[INVENTORY] = INVENTORIES) -> Array[Vector2]:
	# immobile inventories only
	var return_list: Array[Vector2]
	for inventory:INVENTORY in inv_list:
		if inventory.OWNER is NPC: continue
		return_list.append(inventory.OWNER.LOCATION)
	return return_list


func print_inventory_at_location(loc: Vector2) -> void:
	# immobile inventories only
	var inventory: INVENTORY = get_inventory_at_location(loc)
	print(inventory)

func get_locations_of_tag(tag:String) -> Array[Vector2]:
	var inventories: Array[INVENTORY] = filter_inventories_by_tag(tag)
	var return_list: Array[Vector2]
	for inventory:INVENTORY in inventories:
		var loc: Vector2 = inventory.OWNER.LOCATION
		return_list.append(loc)
	return return_list
	


#endregion tile/furniture
