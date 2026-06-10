class_name TILE extends TextureRect

var ID: String
var NAME: String
var TYPE: String
var LOCATION: Vector2
var DATA:Dictionary


func _init(loc:Vector2, type:String="empty") -> void:
	ID = "tile" + str(Global.get_counter())
	TYPE = type
	NAME = type
	LOCATION = loc
	update_type(type)
	add_loc_label()
	# DATA = Constants.TILE_TEMPLATES[TYPE]
	# texture = load("res://models/" + DATA["sprite"])

func in_range(_loc:Vector2) -> bool:
	var distance:float = _loc.distance_to(LOCATION)
	var range:Array = DATA["interactable_range"]
	if distance >= range[0] and distance <= range[1]:
		return true
	return false

func has_tag(tag:String) -> bool:
	var tag_list:Array = DATA["tags"]
	return tag in tag_list


func add_loc_label() -> void:
	var initial_label:Label = Label.new()
	initial_label.text = str(int(LOCATION[0])) + "," + str(int(LOCATION[1]))
	initial_label.position += Vector2(5,0)
	add_child(initial_label)


func update_type(new_type:String="empty") -> void:
	TYPE = new_type
	DATA = Constants.TILE_TEMPLATES[new_type]
	NAME = TYPE + " " + str(LOCATION)
	NAME = TYPE + " " + str(LOCATION)
	texture = load("res://models/" + DATA["sprite"])


func populate_journal(menu, engine, _subentry:String) -> void:
	print("populating entry for: ", NAME)
	menu.update_title(NAME)

	var new_label:Label = Label.new()
	new_label.text = "LOCATION: " + engine.prettify_vector(LOCATION)
	menu.add_to_entry(new_label)


	var inventory_label:Label = Label.new()
	inventory_label.text = "INVENTORY"
	menu.add_to_entry(inventory_label)

	var inventory:INVENTORY = engine.InventoryManager.get_inventory_of(ID)
	var inventory_wiki:Wiki = inventory.to_wiki()
	menu.add_to_entry(inventory_wiki)
	# var inventory_summary:Array = inventory.get_summary()
	# for i:Dictionary in inventory_summary:
	# 	var new_display:RichTextLabel = i["item"].create_display(i["count"])
	# 	menu.add_to_entry(new_display)


func _to_string():
	return "Tile: " + TYPE + " at " + str(LOCATION)
