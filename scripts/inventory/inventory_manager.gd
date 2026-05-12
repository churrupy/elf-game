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
	#print("adding", item, "to", owner.NAME, "'s inventory")
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
		print("tag:", tag)
		print(get_inventory_of(owner.ID))
		print("CRASH!")
	remove_from_inventory(owner, chosen_item)
	return chosen_item


func get_first_tagged_from_inventory(owner:Node, tag:String) -> ITEM:
	var inventory:INVENTORY = get_inventory_of(owner.ID)
	for item: ITEM in inventory.ITEMS:
		if tag in item.TAGS:
			return item
	return null


func inventory_has_tag(owner:Node, tag:String) -> bool:
	var inventory:INVENTORY = get_inventory_of(owner.ID)
	var all_tags:Array[String] = inventory.get_all_tags()
	return tag in all_tags
	# for item: ITEM in inventory.ITEMS:
	# 	if tag in item.TAGS:
	# 		return true
	# return false

func inventory_has_item(owner:Node, item:ITEM) -> bool:
	var inventory:INVENTORY = get_inventory_of(owner.ID)
	for checked_item:ITEM in inventory.ITEMS:
		if item.TYPE == checked_item.TYPE: return true
	return false



func update_inventory_owner(new_owner:Node) -> void:
	# i can't believe how i stumbled into how stupid this is lol
	var inventory:INVENTORY = get_inventory_of(new_owner.ID) # should have the same id
	inventory.OWNER = new_owner






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
		#print(inventory_list)
		push_error("Multiple inventories at ", ENGINE.prettify_vector(loc))
		return null



func get_inventory_locations(inv_list:Array[INVENTORY] = INVENTORIES) -> Array[Vector2]:
	# immobile inventories only
	var res_list: Array[Vector2]
	for inventory:INVENTORY in inv_list:
		if inventory.OWNER is NPC: continue
		res_list.append(inventory.OWNER.LOCATION)
	return res_list


func print_inventory_at_location(loc: Vector2) -> void:
	# immobile inventories only
	var inventory: INVENTORY = get_inventory_at_location(loc)
	#print(inventory)



#endregion tile/furniture


func _to_string() -> String:
	var display_list:Array[String]
	for inv:INVENTORY in INVENTORIES:
		display_list.append(str(inv))
	return " ".join(display_list)
