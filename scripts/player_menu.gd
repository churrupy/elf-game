class_name PLAYER_MENU extends Control

var ENGINE
var PLAYER
var CURRENT_ENTRY:String = "Inventory"

var BG:TextureRect
var TITLE:Label
var NAV_MENU:HFlowContainer

var SCROLL_CONTAINER:ScrollContainer
var ENTRY:VBoxContainer

var PLAYER_BUTTON:Button
var CLOSE_BUTTON:Button

var TOGGLEABLE:Array

#region init
func _init(engine) -> void:
	ENGINE = engine
	# PLAYER = ENGINE.get_node("Player")
	set_player_button()
	set_background()
	set_title()
	set_navigation()
	set_entry()
	set_close_button()

	TOGGLEABLE = [
		BG,
		TITLE,
		NAV_MENU,
		SCROLL_CONTAINER,
		ENTRY,
		CLOSE_BUTTON
	]

func set_player_button() -> void:
	PLAYER_BUTTON = Button.new()
	PLAYER_BUTTON.text = "Player"
	PLAYER_BUTTON.focus_mode = FocusMode.FOCUS_NONE
	PLAYER_BUTTON.position = Vector2(250,50)
	PLAYER_BUTTON.connect("pressed", toggle_menu)
	add_child(PLAYER_BUTTON)

func set_background() -> void:
	BG = TextureRect.new()
	BG.texture = load("res://models/left_menu.png")
	BG.flip_h = true
	BG.size = Vector2(300,660)
	BG.modulate = Constants.COLOR_LIST.pick_random()
	add_child(BG)

func set_title() -> void:
	TITLE = Label.new()
	# TITLE.text = PLAYER.NAME
	TITLE.size = Vector2(111,45)
	TITLE.position = Vector2(95,0)
	TITLE.add_theme_font_size_override("font_size", 32)
	add_child(TITLE)

func set_navigation() -> void:
	NAV_MENU = HFlowContainer.new()
	NAV_MENU.custom_minimum_size = Vector2(290,40)
	NAV_MENU.position = Vector2(7,47)
	add_child(NAV_MENU)

	var nav_list:Array[String] = [
		"Details",
		"Inventory"
	]

	for n:String in nav_list:
		var new_button:Button = Button.new()
		new_button.text = n
		new_button.focus_mode = FocusMode.FOCUS_NONE
		new_button.connect("pressed", toggle_menu.bind(n))
		NAV_MENU.add_child(new_button)

func set_entry() -> void:
	SCROLL_CONTAINER = ScrollContainer.new()
	SCROLL_CONTAINER.size = Vector2(290, 550)
	SCROLL_CONTAINER.position = Vector2(4,90)
	add_child(SCROLL_CONTAINER)

	ENTRY = VBoxContainer.new()
	ENTRY.custom_minimum_size = Vector2(290,0)
	SCROLL_CONTAINER.add_child(ENTRY)

func set_close_button() -> void:
	CLOSE_BUTTON = Button.new()
	CLOSE_BUTTON.text = "X"
	CLOSE_BUTTON.size = Vector2(30,30)
	CLOSE_BUTTON.position = Vector2(250,0)
	CLOSE_BUTTON.add_theme_font_size_override("font_size", 32)
	CLOSE_BUTTON.connect("pressed", toggle_menu)
	add_child(CLOSE_BUTTON)

func set_player() -> void:
	PLAYER = ENGINE.get_node("Player")
	TITLE.text = PLAYER.NAME


func _ready() -> void:
	position = Vector2(900,0)
	for t in TOGGLEABLE:
		t.hide()
	update()

#endregion init

func update_title(title:String) -> void:
	TITLE.text = title

func toggle_menu(topic:String="") -> void:
	if topic == "" or topic == CURRENT_ENTRY:
		for t in TOGGLEABLE:
			t.visible = !t.visible

	else:
		CURRENT_ENTRY = topic
		for t in TOGGLEABLE:
			t.show()

	update()

func update() -> void:
	if PLAYER == null: return # i can't tell the creation order of all these lol
	for child in ENTRY.get_children():
		child.queue_free()

	var options:Dictionary[String, Callable] = {
		"Details": show_details,
		"Inventory": show_inventory,
	}

	if CURRENT_ENTRY in options.keys():
		options[CURRENT_ENTRY].call()
		return


func show_details() -> void:
	update_title("Details")
	
	var new_label:Label = Label.new()
	new_label.text = "Name: " + PLAYER.NAME
	ENTRY.add_child(new_label)

func show_inventory() -> void:
	update_title("Inventory")

	var repeat_items:Array[String]

	var inventory:INVENTORY = ENGINE.InventoryManager.get_inventory_of("player")
	print("inventory check:", inventory)
	for i:ITEM in inventory.ITEMS:
		if i.NAME not in repeat_items:
			var amount:int = inventory.count_item(i.NAME)
			var new_display:RichTextLabel = i.create_display(amount)
			ENTRY.add_child(new_display)
			repeat_items.append(i.NAME)
