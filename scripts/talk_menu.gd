extends Label

#class_name Talk_Menu

var ENGINE
var LOCATION # "center" of conversation,  might not actually be the npc themselves (eg gathering around a table, etc)
var MENU_NPC
var DIALOGUE_LIST = []

@export var conversation_button_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update() -> void:
	if MENU_NPC == null:
		return
	
	# cleanup
	$NameLabel.text = MENU_NPC.NAME
	for child in $TalkDetails.get_node("DialogueContainer").get_node("VBoxContainer").get_children():
		child.queue_free()

	for child in $TalkDetails.get_node("DialogueDetails").get_children():
		child.queue_free()


	var involved_npcs:Array[String] = [] # fix this in a second
	var history_strings:Array[String] = ENGINE.History.populate_talk_menu(MENU_NPC.ID).slice(-10,-1)
	for string:String in history_strings:
		var label: Label = Label.new()
		label.text = string
		var container_size: Vector2 = $TalkDetails.get_node("DialogueContainer").get_node("VBoxContainer").get_size()
		label.custom_minimum_size = Vector2(container_size[0]*.75, 1)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$TalkDetails.get_node("DialogueContainer").get_node("VBoxContainer").add_child(label)

	# set scrollbar to bottom hopefully
	# looks kinda awkward but does technically work
	$TalkDetails.get_node("DialogueContainer").scroll_vertical = $TalkDetails.get_node("DialogueContainer").get_v_scroll_bar().max_value



# func update_old():
# 	if MENU_NPC == null: 
# 		return
# 	var history: Array[HistoryEvent] = ENGINE.History.filter_by_npc(MENU_NPC.ID).slice(-20, -1)
# 	#var history_list = ENGINE.History.history_to_string(history)
# 	#LOCATION = npc.ACTION.TARGET
# 	$NameLabel.text = MENU_NPC.NAME
# 	for child in $TalkDetails.get_node("DialogueContainer").get_node("VBoxContainer").get_children():
# 		child.queue_free()

# 	for child in $TalkDetails.get_node("DialogueDetails").get_children():
# 		child.queue_free()
	
# 	var involved_npcs: Array = []
# 	for item: HistoryEvent in history:
# 		if item.DIALOGUE != "":
			
# 			var label: Label = Label.new()
# 			label.text = item.DIALOGUE
# 			var container_size: Vector2 = $TalkDetails.get_node("DialogueContainer").get_node("VBoxContainer").get_size()
# 			label.custom_minimum_size = Vector2(container_size[0]*.75, 1)
# 			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
# 			$TalkDetails.get_node("DialogueContainer").get_node("VBoxContainer").add_child(label)

# 			for w: String in item.WITNESSES:
# 				if w == MENU_NPC.ID: continue
# 				if w not in involved_npcs: involved_npcs.append(w)
		
# 	for npc_id: String in involved_npcs:
# 		var npc: NPC = Global.NPCS[npc_id]
# 		var name_button = buttons.instantiate()
# 		name_button.initialize(npc)
# 		$TalkDetails.get_node("DialogueDetails").add_child(name_button)

	

func do_dialogue_choice(topic):
	# what PC does
	#RECENT_TOPIC = topic
	print("player chose:", topic)
	# REMINDER: signal emits from location, if you're trying to talk to an npc far away, they won't hear the signal
	SignalBus.say_topic.emit("player", topic, 100, Global.FOCUS_LOCATION)
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
	MENU_NPC = null
	SignalBus.close_talk_menu.emit()


func close_hover() -> void:
	pass # Replace with function body.


func sprite_clicked():
	SignalBus.open_npc_menu.emit()
