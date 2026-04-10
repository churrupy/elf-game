extends Control

var ENGINE
var MENU_NPC: NPC
var WATCH: bool = false
var KEEP_OPEN: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UnWatchButton.hide()
	$BG.modulate = Constants.COLOR_LIST.pick_random()

func _process(delta: float) -> void:
	pass

	
func update():
	# clear menu
	for child in $NpcHistoryContainer.get_node("VBoxContainer").get_children():
		child.queue_free()

	update_npc_details()
	update_history()
	update_portrait()

	SignalBus.npc_hover.emit(MENU_NPC)

func update_npc_details() -> void:
	$NameLabel.text = MENU_NPC.NAME
	var display_string = []
	var _str = "Id: " + MENU_NPC.ID
	display_string.append(_str)
	_str = "Gender: " + MENU_NPC.GENDER
	display_string.append(_str)
	_str = "Current Location: " + str(MENU_NPC.LOCATION)
	display_string.append(_str)
	_str = "Current Action: " + str(MENU_NPC.STATE_STACK.back())
	display_string.append(_str)

	var looking_at_loc: Vector2 = MENU_NPC.LOCATION + MENU_NPC.DIRECTION
	var looking_at:Array[String] = ENGINE.NpcManager.get_npc_from_location(looking_at_loc)
	#var looking_at_string: String = ", ".join(looking_at)
	_str = "Looking At: " + ", ".join(looking_at)
	display_string.append(_str)

	_str = "Current Topic: " + str(MENU_NPC.SOCIAL_ACTION.RECENT_TOPIC)
	display_string.append(_str)
	
	'''
	for need in MENU_NPC.NEEDS:
		_str = need.capitalize() + ": " + str(int(MENU_NPC.NEEDS[need]))
		display_string.append(_str)
	'''

	for item in display_string:
		var new_label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$NpcHistoryContainer.get_node("VBoxContainer").add_child(new_label)

func update_history() -> void:
	# get last five moves
	var history_strings:Array[String] = ENGINE.History.populate_npc_menu(MENU_NPC.ID)
	history_strings.reverse()
	for item:String in history_strings:
		var new_label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$NpcHistoryContainer.get_node("VBoxContainer").add_child(new_label)
	

func update_portrait() -> void:
	$Portrait.update(MENU_NPC)

func update_portrait_old() -> void:
	return
	$Portrait.get_node("Splash").modulate = MENU_NPC.EYE_COLOR
	for part in MENU_NPC.PORTRAIT.keys():
		var sprite = Sprite2D.new()
		var pathfile = MENU_NPC.PORTRAIT[part]
		sprite.texture = load(pathfile)
		if part == "eyes":
			sprite.modulate = MENU_NPC.EYE_COLOR
		elif part in ["bangs", "hair"]:
			sprite.modulate = MENU_NPC.HAIR_COLOR
		elif part in ["body", "ears"]:
			sprite.modulate = MENU_NPC.SKIN_COLOR
		sprite.scale = Vector2(1.2,1.2)
		$Portrait.add_child(sprite)
	$Portrait.global_position = Vector2(68,84)




func close_npc_menu() -> void:
	SignalBus.close_npc_menu.emit()
	SignalBus.npc_hover_off.emit(MENU_NPC)


func watch_npc() -> void:
	WATCH = true
	ENGINE.update_focus_target(MENU_NPC.ID)
	#$WatchButton.icon = load("red://models/watch_glow.png")
	$WatchButton.hide()
	$UnWatchButton.show()
	


func unwatch_npc() -> void:
	WATCH = false
	ENGINE.update_focus_target("player")
	#$WatchButton.icon = load("res://models/watch.png")

	$UnWatchButton.hide()
	$WatchButton.show()

func toggle_watch_npc() -> void:
	print("toggling")
	var focus_target
	if WATCH:
		$WatchButton.icon = load("res://models/watch.png")
		WATCH = false
		focus_target = "player"
	else:
		$WatchButton.icon = load("red://models/watch_glow.png")
		WATCH = true
		focus_target = MENU_NPC.ID


func open_talk_menu() -> void:
	SignalBus.open_talk_menu.emit(MENU_NPC)

func toggle_talk_menu() -> void:
	SignalBus.toggle_talk_menu.emit(MENU_NPC)


func open_journal() -> void:
	SignalBus.update_journal.emit(MENU_NPC)
