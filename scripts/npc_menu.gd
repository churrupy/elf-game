extends Control

var ENGINE
var MENU_NPC
var WATCH = false

signal close_npc_menu_signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UnWatchButton.hide()

func _process(delta: float) -> void:
	pass

	
func tick():
	$NameLabel.text = MENU_NPC.NAME
	var display_string = []
	var _str = "Id: " + MENU_NPC.ID
	display_string.append(_str)
	_str = "Gender: " + MENU_NPC.GENDER
	display_string.append(_str)
	_str = "Current Location: " + str(MENU_NPC.LOCATION)
	display_string.append(_str)
	_str = "Current Action: " + str(MENU_NPC.ACTION)
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
	var history = ENGINE.History.filter_by_doer(MENU_NPC)
	var history_list = ENGINE.History.history_to_string(history)
	var last_five = history_list.slice(-10,-1)
	last_five.reverse()
	display_string += last_five
	
	for item in display_string:
		var new_label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$NpcHistoryContainer.get_node("VBoxContainer").add_child(new_label)

	$Portrait.get_node("Splash").modulate = MENU_NPC.COLOR

	SignalBus.npc_hover.emit(MENU_NPC)


func close_npc_menu() -> void:
	SignalBus.close_npc_menu.emit()
	SignalBus.npc_hover_off.emit(MENU_NPC)


func watch_npc() -> void:
	WATCH = true
	$WatchButton.hide()
	$UnWatchButton.show()
	


func unwatch_npc() -> void:
	WATCH = false
	$UnWatchButton.hide()
	$WatchButton.show()


func open_talk_menu() -> void:
	SignalBus.open_talk_menu.emit(MENU_NPC)
