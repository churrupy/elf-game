extends Control

var DISPLAYED_NPC
var WATCH = false

signal close_npc_menu_signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UnWatchButton.hide()

func _process(delta: float) -> void:
	if DISPLAYED_NPC != null:
		initialize(DISPLAYED_NPC)

	
func initialize(npc):
	DISPLAYED_NPC = npc
	$NameLabel.text = npc.NAME
	var display_string = []
	var _str = "Id: " + npc.ID
	display_string.append(_str)
	_str = "Gender: " + npc.GENDER
	display_string.append(_str)
	_str = "Current Location: " + str(npc.LOCATION)
	display_string.append(_str)
	_str = "Current Action: " + str(npc.ACTION)
	display_string.append(_str)
	
	for need in npc.NEEDS:
		_str = need.capitalize() + ": " + str(int(npc.NEEDS[need]))
		display_string.append(_str)
		
	var display = "\n".join(display_string)
	$NpcDescription.text = display

	SignalBus.npc_hover.emit(DISPLAYED_NPC)


func close_menu() -> void:
	SignalBus.close_npc_menu.emit()
	SignalBus.npc_hover_off.emit(DISPLAYED_NPC)


func watch_npc() -> void:
	WATCH = true
	$WatchButton.hide()
	$UnWatchButton.show()
	


func unwatch_npc() -> void:
	WATCH = false
	$UnWatchButton.hide()
	$WatchButton.show()
