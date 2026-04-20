extends Label

#class_name Talk_Menu

var ENGINE
var LOCATION # "center" of conversation,  might not actually be the npc themselves (eg gathering around a table, etc)
var MENU_NPC:NPC
var DIALOGUE_LIST = []

@export var conversation_button_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BG.modulate = Constants.COLOR_LIST.pick_random()
	SignalBus.toggle_talk_menu.connect(toggle_talk_menu)
	#$CloseButton.connect("pressed", toggle_talk_menu.bind(MENU_NPC))

func update() -> void:
	if MENU_NPC == null:
		return

	$NameLabel.text = MENU_NPC.NAME
	for child in $DialogueContainer_new.get_node("VBoxContainer").get_children():
		child.queue_free()

	var dialogue_list: Array[Wiki] = MENU_NPC.get_talk_menu_display()
	for d: Wiki in dialogue_list:
		$DialogueContainer_new.get_node("VBoxContainer").add_child(d)


	

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func toggle_talk_menu(npc:NPC) -> void:
	if visible:
		if npc == MENU_NPC:
			visible = !visible
		else:
			MENU_NPC = npc
	else:
		MENU_NPC = npc
		visible = true
	update()

func close_talk_menu() -> void:
	toggle_talk_menu(MENU_NPC)


func sprite_clicked():
	SignalBus.open_npc_menu.emit()
