class_name TILE extends TextureRect

var ID: String
var NAME: String
var TYPE: String
var FLOOR_TYPE:String
var LOCATION: Vector2
var DATA:Dictionary

var FLOOR:TextureRect
var FURNITURE:TextureRect


func _init(loc:Vector2, type:String="empty") -> void:
	ID = "tile" + str(Global.get_counter())
	TYPE = type
	NAME = TYPE + " " + str(LOCATION)
	LOCATION = loc

	FLOOR = TextureRect.new()
	add_child(FLOOR)
	FURNITURE = TextureRect.new()
	add_child(FURNITURE)

	update_type(type)
	add_loc_label()

func in_range(_loc:Vector2) -> bool:
	var distance:float = _loc.distance_to(LOCATION)
	var interactable_range:Array = DATA["interactable_range"]
	if distance >= interactable_range[0] and distance <= interactable_range[1]:
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
	if TYPE != "empty":
		FURNITURE.texture = load("res://models/" + DATA["sprite"])
		FURNITURE.modulate = Color(0.796,0.722,0.663)

func update_floor(new_type:String="floor") -> void:
	FLOOR_TYPE = new_type
	var png_name:String = Constants.FLOOR_LIST[FLOOR_TYPE]
	FLOOR.texture = load("res://models/" + png_name)
	FLOOR.modulate = Color(.204,.278,.337)


func populate_journal(menu, engine, _subentry:String) -> void:
	menu.update_title(NAME)

	var new_label:Label = Label.new()
	new_label.text = "LOCATION: " + Global.prettify_vector(LOCATION)
	menu.add_to_entry(new_label)


	var inventory_label:Label = Label.new()
	inventory_label.text = "INVENTORY"
	menu.add_to_entry(inventory_label)

	var inventory:INVENTORY = engine.InventoryManager.get_inventory_of(ID)
	var inventory_wiki:Wiki = inventory.to_wiki()
	menu.add_to_entry(inventory_wiki)



func _to_string():
	return "Tile: " + TYPE + " at " + str(LOCATION)
