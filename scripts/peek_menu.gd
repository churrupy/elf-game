class_name PEEK_MENU extends Control

var ENGINE
var FOCUS:Node

var EXPAND_BUTTON:Button
var WATCH_BUTTON:Button

var SNAP:RichTextLabel = RichTextLabel.new()

var EXPANDED: bool = false
var WATCH:bool = false
var HOLD_OPEN:bool = false

# Godot Challenge To Not Get In My Way failed vvv
var ALIGNMENT = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT


func _init(engine, focus:Node) -> void:
	ENGINE = engine
	FOCUS = focus
	
	init_background()
	init_content()
	init_buttons()
	if focus is NPC:
		init_portrait()

	SNAP.position = Vector2(105,70)
	SNAP.custom_minimum_size = Vector2(200,90)
	add_child(SNAP)

	size = Vector2(300,200)
	custom_minimum_size = Vector2(300,200)
	clip_contents = true
	# print(get_children())

	update()

func init_background() -> void:
	var BG:TextureRect = TextureRect.new()
	BG.texture = load("res://models/left_menu.png")
	BG.custom_minimum_size = Vector2(300,300)
	BG.modulate = Constants.COLOR_LIST.pick_random()
	add_child(BG)

func init_content() -> void:
	var name_label:Label = Label.new()
	name_label.add_theme_font_size_override("font_size", 24)
	if FOCUS is NPC:
		name_label.text = FOCUS.NAME
	else:
		name_label.text = FOCUS.TYPE
	name_label.position = Vector2(140,0)
	add_child(name_label)

func init_buttons() -> void:
	var close_button:Button = Button.new()
	close_button.text = "X"
	close_button.size = Vector2(32,32)
	close_button.add_theme_font_size_override("font_size", 24)
	#close_button.font_size = 24
	close_button.position = Vector2(260,0)
	close_button.connect("pressed", close_menu)
	add_child(close_button)

	var nav_bar_x:int = 100
	var nav_bar_y:int = 35
	var distance_bt_buttons:int = 45


	var talk_button:Button = Button.new()
	talk_button.text = "Talk"
	talk_button.focus_mode = FocusMode.FOCUS_NONE
	talk_button.position = Vector2(nav_bar_x, nav_bar_y)
	talk_button.connect("pressed", toggle_talk_menu)
	add_child(talk_button)

	nav_bar_x += distance_bt_buttons

	var journal_button:Button = Button.new()
	journal_button.icon = ResourceLoader.load("res://models/journal.png")
	journal_button.scale = Vector2(.70,.70)
	journal_button.focus_mode = FocusMode.FOCUS_NONE
	journal_button.position = Vector2(nav_bar_x, nav_bar_y)
	journal_button.connect("pressed", toggle_journal)
	add_child(journal_button)

	nav_bar_x += distance_bt_buttons

	WATCH_BUTTON = Button.new()
	WATCH_BUTTON.icon = ResourceLoader.load("res://models/watch.png")
	WATCH_BUTTON.scale = Vector2(.75,.75)
	WATCH_BUTTON.focus_mode = FocusMode.FOCUS_NONE
	WATCH_BUTTON.position = Vector2(nav_bar_x, nav_bar_y)
	WATCH_BUTTON.connect("pressed", toggle_watch)
	add_child(WATCH_BUTTON)

	EXPAND_BUTTON = Button.new()
	EXPAND_BUTTON.text = "VV"
	EXPAND_BUTTON.position = Vector2(150,170)
	EXPAND_BUTTON.focus_mode = FocusMode.FOCUS_NONE
	EXPAND_BUTTON.connect("pressed", toggle_expand)
	add_child(EXPAND_BUTTON)


func init_portrait() -> void:
	var portrait:Portrait = Portrait.new()
	portrait.update(FOCUS)
	portrait.position = Vector2(10,10)
	add_child(portrait)


func update() -> void:
	print("Updating peek menu")

	# for child in $Large.get_node("DetailContainer").get_children():
	# 	child.queue_free()
	if FOCUS is NPC:
		update_npc()
	elif FOCUS is TILE:
		update_tile()

func update_npc() -> void:
	#print("updating npc menu")
	SNAP.text = ""
	# SNAP = RichTextLabel.new()
	# SNAP.position = Vector2(105,70)
	# SNAP.custom_minimum_size = Vector2(200,90)

	SNAP.push_paragraph(ALIGNMENT)
	SNAP.push_bold()
	SNAP.add_text("ID: ")
	SNAP.pop()
	SNAP.add_text(FOCUS.ID)
	SNAP.pop()

	SNAP.push_paragraph(ALIGNMENT)
	SNAP.push_bold()
	SNAP.add_text("Location: ")
	SNAP.pop()
	SNAP.add_text(ENGINE.prettify_vector(FOCUS.LOCATION))
	SNAP.pop()

	SNAP.push_paragraph(ALIGNMENT)
	SNAP.push_bold()
	SNAP.add_text("Action: ")
	SNAP.pop()
	SNAP.add_text(str(FOCUS.STATE_STACK.back()))
	SNAP.pop()


	var filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().in_range_of(FOCUS.LOCATION, 1.5).in_arc_of(FOCUS.DIRECTION).is_not([FOCUS])
	var _can_see_npc_list:Array[NPC] = filter.run_filter()
	var _can_see_names:Array[String] = ENGINE.NpcManager.get_npc_names(_can_see_npc_list)
	SNAP.push_paragraph(ALIGNMENT)
	SNAP.push_bold()
	SNAP.add_text("Facing: ")
	SNAP.pop()
	SNAP.add_text(", ".join(_can_see_names))
	SNAP.pop()


func update_tile() -> void:
	#print("updating tile menu")
	SNAP.text = ""

	SNAP.push_paragraph(ALIGNMENT)
	SNAP.push_bold()
	SNAP.add_text("Inventory: ")
	SNAP.pop()
	
	var inventory:INVENTORY = ENGINE.InventoryManager.get_inventory_of(FOCUS.ID)
	SNAP.add_text(str(inventory))
	SNAP.pop()


	# add_child(SNAP)


# func update_npc_old() -> void:
# 	print("updating npc menu")
# 	var detail_container:VBoxContainer = VBoxContainer.new()
# 	detail_container.position = Vector2(100,70)
# 	detail_container.custom_minimum_size = Vector2(200,90)
# 	detail_container.add_theme_constant_override("separation", -3)
	
# 	# above expand
# 	# action information (where they are, what they're doing, who they're facing)
# 	var display_string = []
# 	var _str = "Id: " + FOCUS.ID
# 	display_string.append(_str)
# 	_str = "Location: " + ENGINE.prettify_vector(FOCUS.LOCATION)
# 	display_string.append(_str)
# 	_str = "Action: " + str(FOCUS.STATE_STACK.back())
# 	display_string.append(_str)
# 	# _str = "Facing: " + ENGINE.prettify_vector(FOCUS.DIRECTION)
# 	# display_string.append(_str)
# 	var filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().in_range_of(FOCUS.LOCATION, 1.5).in_arc_of(FOCUS.DIRECTION)
# 	var _can_see_npc_list:Array[NPC] = filter.run_filter()
# 	var _can_see_names:Array[String] = ENGINE.NpcManager.get_npc_names(_can_see_npc_list)
# 	_str = "Facing: " + ", ".join(_can_see_names)
# 	display_string.append(_str)


# 	var y_value:int = 10
# 	for item: String in display_string:
# 		var new_label = Label.new()
# 		new_label.text = item
# 		new_label.add_theme_font_size_override("font_size", 14)
# 		new_label.add_theme_constant_override("separateion", -3)
# 		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
# 		new_label.custom_minimum_size = Vector2(200, 15)
# 		# new_label.position = Vector2(50, y_value)
# 		# y_value += 10
# 		detail_container.add_child(new_label)

# 	add_child(detail_container)
# 	# print(get_children())
# 	# print(detail_container.get_children())
# 	# below expand
# 	# identity information (who they are)


# func update_npc() -> void:
# 	# print("EXPANDED BUTTON:", EXPAND_BUTTON.position)
# 	var display_string = []
# 	var _str = "Id: " + FOCUS.ID
# 	display_string.append(_str)
# 	_str = "Gender: " + FOCUS.GENDER
# 	display_string.append(_str)
# 	_str = "Current Location: " + ENGINE.prettify_vector(FOCUS.LOCATION)
# 	display_string.append(_str)
# 	_str = "Currently Reserved: " + ENGINE.prettify_vector(ENGINE.NpcManager.get_reserved_tile(FOCUS))
# 	display_string.append(_str)
# 	_str = "Current Action: " + str(FOCUS.STATE_STACK.back())
# 	display_string.append(_str)
# 	_str = "Inventory: " + str(ENGINE.InventoryManager.get_inventory_of(FOCUS.ID))
# 	display_string.append(_str)
# 	_str = "Facing: " + ENGINE.prettify_vector(FOCUS.DIRECTION)
# 	display_string.append(_str)

# 	var filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().in_range_of(FOCUS.LOCATION, 1.5).in_arc_of(FOCUS.DIRECTION)
# 	var _can_see_npc_list:Array[NPC] = filter.run_filter()

# 	#var _can_see_npc_list: Array[NPC] = ENGINE.NpcManager.can_see(FOCUS)
# 	var _can_see_names:Array[String] = ENGINE.NpcManager.get_npc_names(_can_see_npc_list)
# 	_str = "Looking At: " + ", ".join(_can_see_names)
# 	display_string.append(_str)

# 	_str = "Current Topic: " + str(FOCUS.SOCIAL_ACTION.RECENT_TOPIC)
# 	display_string.append(_str)

# 	for item: String in display_string:
# 		var new_label = Label.new()
# 		new_label.text = item
# 		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
# 		new_label.custom_minimum_size = Vector2(Constants.LEFT_PANEL_SIZE[0], 30)
# 		# $Large.get_node("DetailContainer").add_child(new_label)



func close_menu() -> void:
	# FOCUS.GLOW_SPRITE.hide()
	HOLD_OPEN = false
	WATCH = false
	ENGINE.update_focus_target("player")

func toggle_expand() -> void:
	if EXPANDED:
		EXPANDED = false
		EXPAND_BUTTON.text = "VV"
		EXPAND_BUTTON.position = Vector2(150,160)
		custom_minimum_size = Vector2(300,200)
	else:
		EXPANDED = true
		EXPAND_BUTTON.text = "^^"
		EXPAND_BUTTON.position = Vector2(150,350)
		custom_minimum_size = Vector2(300,400)
		

# func expand_menu() -> void:
# 	# $Small.hide()
# 	# $Large.show()
# 	custom_minimum_size = Vector2(300,400)
# 	# custom_minimum_size = $Large.custom_minimum_size


# func contract_menu() -> void:
# 	# $Large.hide()
# 	# $Small.show()
# 	custom_minimum_size = Vector2(300,200)
# 	# custom_minimum_size = $Small.custom_minimum_size


# func open_journal() -> void:
# 	SignalBus.update_journal.emit(FOCUS)

func toggle_journal() -> void:
	SignalBus.toggle_journal.emit(FOCUS.ID)

# func open_talk_menu() -> void:
# 	SignalBus.open_talk_menu.emit(FOCUS)

func toggle_talk_menu() -> void:
	SignalBus.toggle_talk_menu.emit(FOCUS)

func toggle_watch() -> void:
	if WATCH:
		WATCH = false
		HOLD_OPEN = false
		ENGINE.update_focus_target("player")
		WATCH_BUTTON.icon = ResourceLoader.load("res://models/watch.png")
	else:
		WATCH = true
		HOLD_OPEN = true
		ENGINE.update_focus_target(FOCUS.ID)
		WATCH_BUTTON.icon = ResourceLoader.load("res://models/watch_glow.png")



# func watch_npc() -> void:
# 	WATCH = true
# 	HOLD_OPEN = true
# 	ENGINE.update_focus_target(FOCUS.ID)
# 	$WatchButton.hide()
# 	$UnWatchButton.show()


# func unwatch_npc() -> void:
# 	WATCH = false
# 	ENGINE.update_focus_target("player")
# 	$UnWatchButton.hide()
# 	$WatchButton.show()
