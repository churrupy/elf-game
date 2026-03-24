extends Label

var DISPLAYED_NPC
var DIALOGUE_LIST = []

@export var conversation_button_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func initialize(npc):
	DISPLAYED_NPC = npc
	$NameLabel.text = DISPLAYED_NPC.NAME
	$ConversationLabel.text = ""
	DIALOGUE_LIST = []
	tick()
	#$ConversationLabel.text = DISPLAYED_NPC.NAME + ": "
	#$ConversationLabel.text += Dialogue.DIALOGUE_STRINGS[DISPLAYED_NPC.RECENT_TOPIC]


func tick():
	# npc says something
	clear_children()
	print("ticking talk menu")
	print("old topic", DISPLAYED_NPC.RECENT_TOPIC)
	var new_topic = Dialogue.get_next_topic(DISPLAYED_NPC.RECENT_TOPIC)
	DISPLAYED_NPC.RECENT_TOPIC = new_topic
	print("new topic", DISPLAYED_NPC.RECENT_TOPIC)
	var opinion = DISPLAYED_NPC.OPINIONS[new_topic]
	var op_str = new_topic.capitalize() + " are "
	if opinion > 75:
		op_str+= "great!"
	elif opinion > 50:
		op_str += "okay."
	elif opinion > 25:
		op_str += "lame."
	else:
		op_str += "terrible!"
	SignalBus.say_topic.emit(DISPLAYED_NPC.ID, new_topic, opinion, DISPLAYED_NPC.LOCATION)
	var _str = DISPLAYED_NPC.NAME + ": " + op_str
	DIALOGUE_LIST.append(_str)

	# process pc replying
	
	var button_x = 270
	var button_y = 100
	var next_topics = Dialogue.CONVERSATION_NODES[new_topic]
	for topic in next_topics:
		var conversation_button = conversation_button_scene.instantiate()
		conversation_button.text = topic.capitalize()
		add_child(conversation_button)
		conversation_button.position = Vector2(button_x, button_y)
		button_y += 40
		conversation_button.connect("pressed", Callable(self, "do_dialogue_choice").bind(topic))

	var font_size = 20
	#var dialogue_height = len(DIALOGUE_LIST) * font_size
	#$ConversationLabel.size = Vector2($ConversationLabel.size[0], dialogue_height)
	#$ConversationLabel.position = Vector2(350, 200)

	$ConversationLabel.text = "\n".join(DIALOGUE_LIST)


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
	DISPLAYED_NPC = null
	SignalBus.close_talk_menu.emit()


func close_hover() -> void:
	print("hovering")
	pass # Replace with function body.
