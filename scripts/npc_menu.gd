extends Control

var DISPLAYED_NPC
var WATCH = false

signal close_npc_menu_signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UnWatchButton.hide()

func _process(delta: float) -> void:
	pass

	
func initialize(npc, history):
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
	_str = "Current Topic: " + str(npc.RECENT_TOPIC)
	display_string.append(_str)
	
	for need in npc.NEEDS:
		_str = need.capitalize() + ": " + str(int(npc.NEEDS[need]))
		display_string.append(_str)

	# get last five moves
	var last_five = history.slice(-10,-1)
	last_five.reverse()
	display_string += last_five
	
	# clear container
	for child in $NpcHistoryContainer.get_node("VBoxContainer").get_children():
		child.queue_free()
	
	for item in display_string:
		var new_label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$NpcHistoryContainer.get_node("VBoxContainer").add_child(new_label)
		
	#var display = "\n".join(display_string)
	#$ScrollContainer.get_node("VBoxContainer").get_node("NpcDescription").text = display
	#print($ScrollContainer.get_node("VBoxContainer").get_node("NpcDescription").text)
	#$NpcDescription.text = display

	$Portrait.get_node("Splash").modulate = npc.COLOR

	SignalBus.npc_hover.emit(DISPLAYED_NPC)


func close_npc_menu() -> void:
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


func talk_pressed() -> void:
	SignalBus.talk_to_npc.emit(DISPLAYED_NPC)
