class_name RECIPE extends RefCounted

var ENGINE
var OWNER:Node
var NAME:String
var DATA:Dictionary

var CRAFTABLE:bool = false

func _init(engine, owner, name) -> void:
	ENGINE = engine
	OWNER = owner
	NAME = name
	# print("running filter")
	
	var filter:RECIPE_FILTER = RECIPE_FILTER.new(ENGINE).set_name(NAME)
	DATA = filter.run_filter()[0]

func validate_recipe() -> void:
	pass

func create_display() -> RichTextLabel:
	print('creating display')
	var craft_tracker:bool = true
	var display:RichTextLabel = RichTextLabel.new()
	# display.custom_minimum_size = Vector2(250,90)
	display.fit_content = true

	# name
	display.push_paragraph(HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT)
	display.push_bold()
	display.add_text(NAME.capitalize())
	display.pop()
	# display.add_text(NAME)
	display.pop()

	# description
	var description:String = Constants.ITEM_TEMPLATES[NAME]["description"]
	display.push_paragraph(HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT)
	display.push_bold()
	display.add_text("Description: ")
	display.pop()
	display.add_text(description)
	display.pop()

	# required furniture
	display.push_paragraph(HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT)
	display.push_bold()
	display.add_text("Required Furniture:")
	display.pop()
	for f:String in DATA["furniture"]:
		display.push_list(0, RichTextLabel.ListType.LIST_DOTS, false)
		var amount_nearby:int = get_furniture_amount_nearby(f)
		# if is_furniture_nearby(f):
		if amount_nearby > 0:
			display.push_color(Color.GREEN)
		else:
			craft_tracker = false
			display.push_color(Color.RED)
		display.add_text(f)
		display.pop() #color
		display.pop() #list
	display.pop()

	# required tools
	display.push_paragraph(HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT)
	display.push_bold()
	display.add_text("Required Tools:")
	display.pop()
	for t:String in DATA["tools"]:
		display.push_list(0, RichTextLabel.ListType.LIST_DOTS, false)
		var amount_nearby:int = get_item_amount_nearby(t)
		if amount_nearby > 0:
		# if is_item_nearby(t):
			display.push_color(Color.GREEN)
		else:
			craft_tracker = false
			display.push_color(Color.RED)
		display.add_text(t)
		display.pop() # color
		if amount_nearby > 1:
			# print("TOO MANY")
			display.add_text(" (x" + str(amount_nearby) + ")")
		display.pop() # list
	display.pop()

	# required ingredients

	display.push_paragraph(HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT)
	display.push_bold()
	display.add_text("Required Ingredients:")
	display.pop()
	
	for t:String in DATA["ingredients"]:
		display.push_list(0, RichTextLabel.ListType.LIST_DOTS, false)
		var amount_nearby:int = get_item_amount_nearby(t)
		if amount_nearby > 0:
		# if is_item_nearby(t):
			display.push_color(Color.GREEN)
		else:
			craft_tracker = false
			display.push_color(Color.RED)
		display.add_text(t)
		display.pop() # color
		if amount_nearby > 1:
			# print("TOO MANY")
			display.add_text(" (x" + str(amount_nearby) + ")")
		display.pop() #list
	display.pop()

	# print(display.get_parsed_text())
	CRAFTABLE = craft_tracker

	return display


func to_wiki() -> Wiki:
	print("making new wiki")
	var new_wiki:Wiki = Wiki.new()
	# new_wiki.add_text_bold("Recipe:")
	new_wiki.add_text_bold(NAME.capitalize())
	new_wiki.add_newline()

	# new_wiki.add_key_value_label("Description", Constants.ITEM_TEMPLATES[NAME]["description"])
	new_wiki.add_text_bold("Description:")
	new_wiki.add_text(Constants.ITEM_TEMPLATES[NAME]["description"])
	new_wiki.add_newline()
	# new_wiki.add_text("Description: " + DATA["description"])

	# required tools/furniture
	new_wiki.add_text_bold("Required furniture:")
	for f:String in DATA["furniture"]:
		var tile_list:Array[TILE] = get_nearby_furniture(f)
		if len(tile_list) > 0:
			new_wiki.add_button(tile_list[0], Color.GREEN, f)
		else:
			new_wiki.add_text(f, Color.RED)
	new_wiki.add_newline()

	new_wiki.add_text_bold("Required tools: ")
	for t:String in DATA["tools"]:
		var item_list:Array[ITEM] = get_nearby_items(t)
		if len(item_list) > 0:
			new_wiki.add_button(item_list[0], Color.GREEN, t)
		else:
			new_wiki.add_text(t, Color.RED)
	new_wiki.add_newline()

	# required ingredients
	new_wiki.add_text_bold("Required ingredients: ")
	for i:String in DATA["ingredients"]:
		var item_list:Array[ITEM] = get_nearby_items(i)
		if len(item_list) > 0:
			new_wiki.add_button(item_list[0], Color.GREEN, i)
		else:
			new_wiki.add_text(i, Color.RED)
	new_wiki.add_newline()

	# new_wiki.finalize()

	return new_wiki

func to_wiki_old() -> Wiki:
	print("making old wiki")
	var new_wiki:Wiki = Wiki.new()
	new_wiki.add_to_wiki("Recipe: " + NAME)
	new_wiki.add_to_wiki("Description: " + DATA["description"])

	# required tools/furniture
	new_wiki.add_to_wiki("Required furniture: ")
	for f:String in DATA["furniture"]:
		if is_furniture_nearby(f):
			new_wiki.add_to_wiki(f, "label", Color.GREEN)
		else:
			new_wiki.add_to_wiki(f, "label", Color.RED)

	new_wiki.add_to_wiki("Required tools: ")
	for t:String in DATA["tools"]:
		if is_item_nearby(t):
			new_wiki.add_to_wiki(t, "label", Color.GREEN)
		else:
			new_wiki.add_to_wiki(t, "label", Color.RED)

	# required ingredients
	new_wiki.add_to_wiki("Required ingredients: ")
	for i:String in DATA["ingredients"]:
		if is_item_nearby(i):
			new_wiki.add_to_wiki(i, "label", Color.GREEN)
		else:
			new_wiki.add_to_wiki(i, "label", Color.RED)

	return new_wiki

func get_furniture_amount_nearby(furn:String) -> int:
	# print("checking if furniture is nearby: ", furn)
	var tile_filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag(furn).in_range_of(OWNER.LOCATION)
	var filtered_tiles:Array[TILE] = tile_filter.run_filter()
	# print("filtered tiles: ", filtered_tiles)
	# print(OWNER.LOCATION)
	return len(filtered_tiles)

func get_item_amount_nearby(item:String) -> int:
	# print("checking if item is nearby: ", item)
	var inventory_filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().has_tag(item).in_range_of(OWNER.LOCATION).include_owner(OWNER)
	var filtered_inventories:Array[INVENTORY] = inventory_filter.run_filter()
	return ENGINE.InventoryManager.count_tags_in_list(item, filtered_inventories)
 
func is_furniture_nearby(furn:String) -> bool:
	# print("checking if furniture is nearby: ", furn)
	var tile_filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag(furn).in_range_of(OWNER.LOCATION)
	var filtered_tiles:Array[TILE] = tile_filter.run_filter()
	if len(filtered_tiles) > 0:
		return true
	return false

func is_item_nearby(item:String) -> bool:
	# print("checking if item is nearby: ", item)
	var inventory_filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().has_tag(item).in_range_of(OWNER.LOCATION).include_owner(OWNER)
	var filtered_inventory:Array[INVENTORY] = inventory_filter.run_filter()
	if len(filtered_inventory) > 0:
		return true
	else:
		return false

func get_nearby_furniture(id:String) -> Array[TILE]:
	var tile_list:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().has_tag(id).in_range_of(OWNER.LOCATION).run_filter()
	return tile_list

func get_nearby_items(tag:String) -> Array[ITEM]:
	var inventory_list:Array[INVENTORY] = INVENTORY_FILTER.new(ENGINE).set_list().has_tag(tag).in_range_of(OWNER.LOCATION).include_owner(OWNER).run_filter()
	var item_list:Array[ITEM] = []
	for i:INVENTORY in inventory_list:
		item_list += i.get_all_items_tagged_with(tag)
	
	return item_list



func craft() -> void:
	# delete all ingredients
	print("crafting")
	for i:String in DATA["ingredients"]:
		# get inventory
		var inventory_filter:INVENTORY_FILTER = INVENTORY_FILTER.new(ENGINE).set_list().has_tag(i).in_range_of(OWNER.LOCATION).include_owner(OWNER)
		var filtered_inventory:Array[INVENTORY] = inventory_filter.run_filter()
		var chosen_inventory = filtered_inventory[0]
		var item:ITEM = ENGINE.InventoryManager.pop_inventory_first_tagged(chosen_inventory.OWNER, i)

	# create new item
	var new_item:ITEM = ITEM.new(DATA["name"]) # the name is the same as the result of the recipe lol
	ENGINE.InventoryManager.add_to_inventory(OWNER, new_item)
