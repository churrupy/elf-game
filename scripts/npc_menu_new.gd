extends Control

class_name NpcMenuNode

var ENGINE
var DISPLAY_NPC
var HOLD_OPEN: bool = false

var PORTRAIT: Portrait = Portrait.new()
var BG: TextureRect = TextureRect.new()

func _init() -> void:
	#minimum_size = Vector2(300, 300)
	
	pass


func initialize(engine, npc:NPC) -> void:
	#mouse_entered.connect(onhover_menu)
	#$CloseButton.mouse_entered.connect(onhover)
	#$CloseButton.pressed.connect(close_npc_menu)
	#print("initializing")
	#print(visible)
	#print(global_position)
	#print(size)
	ENGINE = engine
	DISPLAY_NPC = npc
	DISPLAY_NPC.GLOW_SPRITE.show()

# func onhover_menu() -> void:
# 	print("check")

# func onhover() -> void:
# 	print("ehlloO!")

func _ready() -> void:
	$BG.modulate = Constants.COLOR_LIST.pick_random()
	$Portrait.update(DISPLAY_NPC)


	$NameLabel.text = DISPLAY_NPC.NAME

	var display_string = []
	var _str = "Id: " + DISPLAY_NPC.ID
	display_string.append(_str)
	_str = "Gender: " + DISPLAY_NPC.GENDER
	display_string.append(_str)
	_str = "Current Location: " + ENGINE.prettify_vector(DISPLAY_NPC.LOCATION)
	display_string.append(_str)
	_str = "Current Action: " + str(DISPLAY_NPC.STATE_STACK.back())
	display_string.append(_str)
	_str = "Facing: " + ENGINE.prettify_vector(DISPLAY_NPC.DIRECTION)
	display_string.append(_str)

	var can_see_list: Array[String] = ENGINE.NpcManager.can_see(DISPLAY_NPC)
	_str = "Looking At: " + ", ".join(can_see_list)
	display_string.append(_str)

	_str = "Current Topic: " + str(DISPLAY_NPC.SOCIAL_ACTION.RECENT_TOPIC)
	display_string.append(_str)

	for item: String in display_string:
		var new_label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		new_label.custom_minimum_size = Vector2(Constants.LEFT_PANEL_SIZE[0], 30)
		$DetailContainer.add_child(new_label)


# func _init_old(engine, npc:NPC) -> void:
# 	ENGINE = engine
# 	DISPLAY_NPC = npc

# 	#custom_minimum_size = Vector2(Constants.LEFT_PANEL_SIZE[0], 300)

# 	BG.texture = load("res://models/left_menu.png")
# 	add_child(BG)

# 	PORTRAIT.update(npc)
# 	add_child(PORTRAIT)

# 	#$NameLabel.text = npc.NAME

# 	var detail_container: VBoxContainer = VBoxContainer.new()
# 	add_child(detail_container)

# 	var name_label: Label = Label.new()
# 	name_label.text = npc.NAME
# 	name_label.custom_minimum_size = Vector2(Constants.LEFT_PANEL_SIZE[0], 30)
# 	detail_container.add_child(name_label)

	

# 	var display_string = []
# 	var _str = "Id: " + npc.ID
# 	display_string.append(_str)
# 	_str = "Gender: " + npc.GENDER
# 	display_string.append(_str)
# 	_str = "Current Location: " + str(npc.LOCATION)
# 	display_string.append(_str)
# 	_str = "Current Action: " + str(npc.STATE_STACK.back())
# 	display_string.append(_str)
# 	_str = "Facing: " + str(npc.DIRECTION)
# 	display_string.append(_str)

# 	var can_see_list: Array[String] = ENGINE.NpcManager.can_see(npc)
# 	_str = "Looking At: " + ", ".join(can_see_list)
# 	display_string.append(_str)

# 	_str = "Current Topic: " + str(npc.SOCIAL_ACTION.RECENT_TOPIC)
# 	display_string.append(_str)

# 	for item: String in display_string:
# 		var new_label = Label.new()
# 		new_label.text = item
# 		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
# 		new_label.custom_minimum_size = Vector2(Constants.LEFT_PANEL_SIZE[0], 30)
# 		detail_container.add_child(new_label)

# 	var close_button: Button = Button.new()
# 	close_button.text = "X"
# 	close_button.pressed.connect(close_npc_menu)
# 	add_child(close_button)

	

func _process(_delta:float) -> void:
	#print($CloseButton.global_position)
	pass

# func update(npc:NPC) -> void:
# 	DISPLAY_NPC = npc
# 	#name_label.text = DISPLAY_NPC.


func close_npc_menu() -> void:
	DISPLAY_NPC.GLOW_SPRITE.hide()
	print("click!")
	HOLD_OPEN = false
	#ENGINE.remove_from_hover(DISPLAY_NPC.ID)
