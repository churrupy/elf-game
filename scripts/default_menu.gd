extends Node

# @export var npc_menus: PackedScene
var ENGINE

var TEMP_NPCS: Array[String]
# var OPEN_MENUS: Dictionary[String, NpcMenuNode]
var OPEN_MENUS: Dictionary[String, Control]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PlayerDetails.get_node("BG").modulate = Constants.COLOR_LIST.pick_random()
		
func _process(_delta:float) -> void:
	for id:String in OPEN_MENUS.keys():
		var menu:Control = OPEN_MENUS[id]
		if id not in TEMP_NPCS and !menu.HOLD_OPEN:
			menu.close_menu()
			menu.queue_free()
			OPEN_MENUS.erase(id)


func update():
	var player_location: Vector2 = ENGINE.get_node("Player").LOCATION
	var location_text: String = "[" + str(int(player_location[0])) + "," + str(int(player_location[1])) + "]"
	$PlayerDetails.get_node("PCLocationLabel").text = location_text
	$PlayerDetails.get_node("TickLabel").text = "T:" + str(Global.TICKS)

	# update side menus
	for child in $NearbyNpcsContainer.get_node("VBoxContainer").get_children():
		if "update" in child:
			child.update()


func open_menus(npc_list:Array[String]) -> void:
	TEMP_NPCS = npc_list.duplicate()
	for id:String in npc_list:
		if id in OPEN_MENUS.keys(): continue
		var item:Node
		if id in Global.NPCS.keys():
			item = Global.NPCS[id]
		else:
			item = ENGINE.Map.get_tile_from_id(id)
		
		var menu: PEEK_MENU = PEEK_MENU.new(ENGINE, item)
		OPEN_MENUS[id] = menu
		$NearbyNpcsContainer.get_node("VBoxContainer").add_child(menu)


func hold_menus(npc_list:Array[String]) -> void:
	for id:String in npc_list:
		var menu: PEEK_MENU = OPEN_MENUS[id]
		menu.HOLD_OPEN = !menu.HOLD_OPEN

