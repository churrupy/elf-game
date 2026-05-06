class_name NpcMenuNode extends Control

var ENGINE
var DISPLAY_NPC
var HOLD_OPEN: bool = false
var WATCH: bool = false

var PORTRAIT: Portrait = Portrait.new()
var BG: TextureRect = TextureRect.new()

func _init() -> void:
	pass


func initialize(engine, npc:NPC) -> void:
	ENGINE = engine
	DISPLAY_NPC = npc
	DISPLAY_NPC.GLOW_SPRITE.show()


func _ready() -> void:
	$BG.modulate = Constants.COLOR_LIST.pick_random()
	$Portrait.update(DISPLAY_NPC)


	$NameLabel.text = DISPLAY_NPC.NAME

	update()


func update() -> void:
	print("UPDATING SIDE MENU")
	for child in $Large.get_node("DetailContainer").get_children():
		child.queue_free()

	var display_string = []
	var _str = "Id: " + DISPLAY_NPC.ID
	display_string.append(_str)
	_str = "Gender: " + DISPLAY_NPC.GENDER
	display_string.append(_str)
	_str = "Current Location: " + ENGINE.prettify_vector(DISPLAY_NPC.LOCATION)
	display_string.append(_str)
	_str = "Currently Reserved: " + ENGINE.prettify_vector(ENGINE.NpcManager.get_reserved_tile(DISPLAY_NPC))
	display_string.append(_str)
	_str = "Current Action: " + str(DISPLAY_NPC.STATE_STACK.back())
	display_string.append(_str)
	_str = "Inventory: " + str(ENGINE.InventoryManager.get_inventory_of(DISPLAY_NPC.ID))
	display_string.append(_str)
	_str = "Facing: " + ENGINE.prettify_vector(DISPLAY_NPC.DIRECTION)
	display_string.append(_str)

	var filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().in_range_of(DISPLAY_NPC.LOCATION, 1.5).in_arc_of(DISPLAY_NPC.DIRECTION)
	var _can_see_npc_list:Array[NPC] = filter.run_filter()

	#var _can_see_npc_list: Array[NPC] = ENGINE.NpcManager.can_see(DISPLAY_NPC)
	var _can_see_names:Array[String] = ENGINE.NpcManager.get_npc_names(_can_see_npc_list)
	_str = "Looking At: " + ", ".join(_can_see_names)
	display_string.append(_str)

	_str = "Current Topic: " + str(DISPLAY_NPC.SOCIAL_ACTION.RECENT_TOPIC)
	display_string.append(_str)

	for item: String in display_string:
		var new_label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		new_label.custom_minimum_size = Vector2(Constants.LEFT_PANEL_SIZE[0], 30)
		$Large.get_node("DetailContainer").add_child(new_label)

func close_npc_menu() -> void:
	DISPLAY_NPC.GLOW_SPRITE.hide()
	HOLD_OPEN = false


func expand_menu() -> void:
	$Small.hide()
	$Large.show()
	custom_minimum_size = $Large.custom_minimum_size


func contract_menu() -> void:
	$Large.hide()
	$Small.show()
	custom_minimum_size = $Small.custom_minimum_size


func open_journal() -> void:
	SignalBus.update_journal.emit(DISPLAY_NPC)

func toggle_journal() -> void:
	SignalBus.toggle_journal.emit(DISPLAY_NPC.ID)

# func open_talk_menu() -> void:
# 	SignalBus.open_talk_menu.emit(DISPLAY_NPC)

func toggle_talk_menu() -> void:
	SignalBus.toggle_talk_menu.emit(DISPLAY_NPC)


func watch_npc() -> void:
	WATCH = true
	HOLD_OPEN = true
	ENGINE.update_focus_target(DISPLAY_NPC.ID)
	$WatchButton.hide()
	$UnWatchButton.show()


func unwatch_npc() -> void:
	WATCH = false
	ENGINE.update_focus_target("player")
	$UnWatchButton.hide()
	$WatchButton.show()
