extends Control

var ENGINE
var MENU_NPC
var WATCH = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UnWatchButton.hide()

func _process(delta: float) -> void:
	pass

	
func update():
	$NameLabel.text = MENU_NPC.NAME
	var display_string = []
	var _str = "Id: " + MENU_NPC.ID
	display_string.append(_str)
	_str = "Gender: " + MENU_NPC.GENDER
	display_string.append(_str)
	_str = "Current Location: " + str(MENU_NPC.LOCATION)
	display_string.append(_str)
	_str = "Current Action: " + str(MENU_NPC.STATE_STACK.back().ID)
	display_string.append(_str)
	_str = "Current Topic: " + str(MENU_NPC.RECENT_TOPIC)
	display_string.append(_str)
	
	for need in MENU_NPC.NEEDS:
		_str = need.capitalize() + ": " + str(int(MENU_NPC.NEEDS[need]))
		display_string.append(_str)
	
	# clear container
	for child in $NpcHistoryContainer.get_node("VBoxContainer").get_children():
		child.queue_free()

	# get last five moves
	var history = ENGINE.History.filter_by_doer(MENU_NPC.ID)
	var history_list = ENGINE.History.history_to_string(history)
	var last_five = history_list.slice(-10,-1)
	last_five.reverse()
	display_string += last_five
	
	for item in display_string:
		var new_label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$NpcHistoryContainer.get_node("VBoxContainer").add_child(new_label)

	#$Portrait.get_node("Splash").modulate = MENU_NPC.HAIR_COLOR
	clear_portrait()
	var splash = TextureRect.new()
	splash.modulate = MENU_NPC.EYE_COLOR
	splash.scale = Vector2(1.2,1.2)
	$Portrait.add_child(splash)
	var background = Sprite2D.new()
	background.texture = load("res://models/portrait/portrait_background.png")
	background.scale = Vector2(1.2,1.2)
	$Portrait.add_child(background)
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

	SignalBus.npc_hover.emit(MENU_NPC)

func clear_portrait():
	for child in $Portrait.get_children():
		child.queue_free()


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
