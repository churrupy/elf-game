extends Node

@export var npc_menus: PackedScene
var ENGINE

var TEMP_NPCS: Array[String]
var OPEN_MENUS: Dictionary[String, NpcMenuNode]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PlayerDetails.get_node("BG").modulate = Constants.COLOR_LIST.pick_random()
		

func _process(_delta:float) -> void:
	for npc_id: String in OPEN_MENUS.keys():
		var npc_menu: NpcMenuNode = OPEN_MENUS[npc_id]
		if npc_id not in TEMP_NPCS and !npc_menu.HOLD_OPEN:
			npc_menu.close_npc_menu()
			npc_menu.queue_free()
			OPEN_MENUS.erase(npc_id)
		

func update():
	var player_location: Vector2 = ENGINE.get_node("Player").LOCATION
	var location_text: String = "[" + str(int(player_location[0])) + "," + str(int(player_location[1])) + "]"
	$PlayerDetails.get_node("PCLocationLabel").text = location_text
	$PlayerDetails.get_node("TickLabel").text = "T:" + str(Global.TICKS)

			
func open_npc_menus_old(npc_list:Array[String]) -> void:
	TEMP_NPCS = npc_list.duplicate()
	for npc_id:String in npc_list:
		if npc_id not in OPEN_MENUS.keys():
			var npc:NPC = Global.NPCS[npc_id]
			var npc_menu:NpcMenuNode = npc_menus.instantiate()
			npc_menu.initialize(ENGINE, npc)
			OPEN_MENUS[npc_id] = npc_menu
			$NearbyNpcsContainer.get_node("VBoxContainer").add_child(npc_menu)

func open_npc_menus(npc_list:Array[String]) -> void:
	TEMP_NPCS = npc_list.duplicate()
	for id:String in npc_list:
		if id in OPEN_MENUS.keys(): continue
		if id in Global.NPCS.keys():
			var npc:NPC = Global.NPCS[id]
			var npc_menu:NpcMenuNode = npc_menus.instantiate()
			npc_menu.initialize(ENGINE, npc)
			OPEN_MENUS[id] = npc_menu
			$NearbyNpcsContainer.get_node("VBoxContainer").add_child(npc_menu)
		# else:
		# 	# assume if not npc, then is furniture for now
		# 	var furniture: Furniture = ENGINE.Map.get_furniture(id)




func hold_temp_menus() -> void:
	for npc_id: String in TEMP_NPCS:
		var npc_menu:NpcMenuNode = OPEN_MENUS[npc_id]
		npc_menu.HOLD_OPEN = true




func open_journal() -> void:
	SignalBus.open_journal.emit()


func expand_player_details() -> void:
	$PlayerDetails.get_node("Small").hide()
	$PlayerDetails.get_node("Large").show()
	$PlayerDetails.custom_minimum_size = $PlayerDetails.get_node("Large").custom_minimum_size

func contract_player_details() -> void:
	$PlayerDetails.get_node("Large").hide()
	$PlayerDetails.get_node("Small").show()
	$PlayerDetails.custom_minimum_size = $PlayerDetails.get_node("Small").custom_minimum_size
