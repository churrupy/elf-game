extends Label

var ENGINE
var LOCATION # "center" of conversation,  might not actually be the npc themselves (eg gathering around a table, etc)
var MENU_NPC
var DIALOGUE_LIST = []

@export var conversation_button_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func tick():
	var history = ENGINE.History.filter_by_npc(MENU_NPC)
	#var history_list = ENGINE.History.history_to_string(history)
	#LOCATION = npc.ACTION.TARGET
	$NameLabel.text = MENU_NPC.NAME
	for child in $DialogueContainer.get_node("VBoxContainer").get_children():
		child.queue_free()
	
	for item in history:
		var new_label = Label.new()
		if "dialogue" in item["arg"]:
			new_label.text = item["arg"]["dialogue"]
			new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			$DialogueContainer.get_node("VBoxContainer").add_child(new_label)

	

func do_dialogue_choice(topic):
	# what PC does
	#RECENT_TOPIC = topic
	print("player chose:", topic)
	# REMINDER: signal emits from location, if you're trying to talk to an npc far away, they won't hear the signal
	SignalBus.say_topic.emit("player", topic, 100, Global.PLAYER_LOCATION)
	var _str = "Player: " + Dialogue.DIALOGUE_STRINGS[topic]
	DIALOGUE_LIST.append(_str)
	SignalBus.tick_signal.emit()
	#tick()


func clear_children():
	for child in get_children():
		if child is ConversationButton:
			child.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func close_talk_menu() -> void:
	print("talk clicked")
	MENU_NPC = null
	SignalBus.close_talk_menu.emit()


func close_hover() -> void:
	print("hovering")
	pass # Replace with function body.
