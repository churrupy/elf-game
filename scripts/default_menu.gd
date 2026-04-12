extends Node

@export var buttons: PackedScene
@export var npc_menus: PackedScene
var ENGINE

var TEMP_NPCS: Array[String]
var OPEN_MENUS: Dictionary[String, NpcMenuNode]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.modulate = Constants.COLOR_LIST.pick_random()
	pass

# func onhover() -> void:
# 	print("defaultmenu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process_backup(_delta: float) -> void:
# 	for child in $NearbyNpcsContainer.get_node("VBoxContainer").get_children():
# 		child.queue_free()

# 	for npc_id: String in ENGINE.HOVER_NPCS:
# 		var npc:NPC = Global.NPCS[npc_id]
# 		var npc_menu: NpcMenuNode = NpcMenuNode.new()
# 		$NearbyNpcsContainer.get_node("VBoxContainer").add_child(npc_menu)
		

func _process(_delta:float) -> void:
	for npc_id: String in OPEN_MENUS.keys():
		var npc_menu: NpcMenuNode = OPEN_MENUS[npc_id]
		if npc_id not in TEMP_NPCS and !npc_menu.HOLD_OPEN:
			#$NearbyNpcsContainer.get_node("VBoxContainer").remove_child(npc_menu)
			print("closing", npc_id)
			npc_menu.close_npc_menu()
			npc_menu.queue_free()
			OPEN_MENUS.erase(npc_id)
		

# func _process_old(_delta: float) -> void:
# 	#pass
# 	#print(ENGINE.HOVER_NPCS)
	
# 	for npc_id: String in ENGINE.HOVER_NPCS:
# 		var npc:NPC = Global.NPCS[npc_id]
# 		var npc_menu:NpcMenuNode = npc_menus.instantiate()
		
# 		#npc_menu.DISPLAY_NPC = npc
# 		npc_menu.initialize(ENGINE, npc)
# 		$NearbyNpcsContainer.get_node("VBoxContainer").add_child(npc_menu)
# 		#$NearbyNpcsContainer.add_child(npc_menu)
		

func update():
	# for child in $NearbyNpcsContainer.get_node("VBoxContainer").get_children():
	# 	child.queue_free()
	# #print(ENGINE.HOVER_NPCS)
	
	# for npc_id: String in ENGINE.HOVER_NPCS:
	# 	var npc:NPC = Global.NPCS[npc_id]
	# 	var npc_menu:NpcMenuNode = npc_menus.instantiate()
		
	# 	#npc_menu.DISPLAY_NPC = npc
	# 	npc_menu.initialize(ENGINE, npc)
	# 	$NearbyNpcsContainer.get_node("VBoxContainer").add_child(npc_menu)
	# 	#$NearbyNpcsContainer.add_child(npc_menu)


	var player_location: Vector2 = ENGINE.get_node("Player").LOCATION
	var location_text: String = "[" + str(int(player_location[0])) + "," + str(int(player_location[1])) + "]"
	$PCLocationLabel.text = location_text
	$TickLabel.text = "T:" + str(Global.TICKS)
	var player_history = ENGINE.History.filter_by_npc("player")
	var player_history_list = ENGINE.History.history_to_string(player_history)
	var trunc_history = player_history_list.slice(-10, -1)
	trunc_history.reverse()
	# clear container

	'''
	for child in $PlayerHistoryContainer.get_node("VBoxContainer").get_children():
		child.queue_free()
	for item in trunc_history:
		var new_label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$PlayerHistoryContainer.get_node("VBoxContainer").add_child(new_label)
	'''
	'''
	for child in $NearbyNpcsContainer.get_node("VBoxContainer").get_children():
		child.queue_free()
	for npc_id: String in Global.NEARBY_NPCS:
		var npc: NPC = Global.NPCS[npc_id]
		var npc_button = buttons.instantiate()
		npc_button.initialize(npc)
		$NearbyNpcsContainer.get_node("VBoxContainer").add_child(npc_button)
	'''
			
			
func open_npc_menus(npc_list:Array[String]) -> void:
	print(npc_list)
	TEMP_NPCS = npc_list.duplicate()
	for npc_id:String in npc_list:
		if npc_id not in OPEN_MENUS.keys():
			var npc:NPC = Global.NPCS[npc_id]
			var npc_menu:NpcMenuNode = npc_menus.instantiate()
			npc_menu.initialize(ENGINE, npc)
			OPEN_MENUS[npc_id] = npc_menu
			$NearbyNpcsContainer.get_node("VBoxContainer").add_child(npc_menu)


	print(OPEN_MENUS)

func hold_temp_menus() -> void:
	for npc_id: String in TEMP_NPCS:
		var npc_menu:NpcMenuNode = OPEN_MENUS[npc_id]
		npc_menu.HOLD_OPEN = true




# func open_npc_menu(npc):
# 	SignalBus.npc_click.emit(npc)


	


func open_journal() -> void:
	SignalBus.open_journal.emit()
