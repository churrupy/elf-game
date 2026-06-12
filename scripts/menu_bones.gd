class_name MENU_BONES extends Control

var ENGINE

var CURRENT_ENTRY

var SUBENTRY:String

var BG:TextureRect
var TITLE:Label
var BACK_BUTTON:Button
var NAV_MENU:HFlowContainer
var SCROLL_CONTAINER:ScrollContainer
var ENTRY:VBoxContainer

var CLOSE_BUTTON:Button

var TOGGLEABLE:Array


var side_buttons:Array[Button]

var OPEN:bool = false

var HISTORY:Array = []

#region init


func _init(engine) -> void:
	ENGINE = engine

	size = ENGINE.GameWindow.RIGHT_PANEL_SIZE
	
	position = Vector2(ENGINE.GameWindow.SCREEN_SIZE[0], 0) # sliding it over, not hiding it

	init_background()
	init_title()
	init_navigation()
	init_entry()
	init_close_button()


func _ready() -> void:
	SignalBus.connect("update_current_entry", update_current_entry)

	
func init_presets() -> void:
	# initialized after player is initialized
	# player
	var player_button:Button = Button.new()
	player_button.text = "Player"
	player_button.focus_mode = FocusMode.FOCUS_NONE
	var player = ENGINE.get_node("Player")
	bind_button_to_entry(player_button, player)
	add_child(player_button)
	player_button.position = Vector2(-64, 40)
	side_buttons.append(player_button)

	# journal
	var npc_button:Button = Button.new()
	npc_button.icon = ResourceLoader.load("res://models/journal.png")
	# npc_button.scale = Vector2(.70,.70)
	npc_button.focus_mode = FocusMode.FOCUS_NONE
	
	var npc_filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list()
	bind_button_to_entry(npc_button, npc_filter)
	
	add_child(npc_button)
	npc_button.position = Vector2(-64,120)
	side_buttons.append(npc_button)

	# crafting
	var craft_button:Button = Button.new()
	craft_button.text = "Crafting"
	# craft_button.icon = ResourceLoader.load("res://models/")
	craft_button.focus_mode = FocusMode.FOCUS_NONE

	var recipe_filter:RECIPE_FILTER = RECIPE_FILTER.new(ENGINE)
	bind_button_to_entry(craft_button, recipe_filter)

	add_child(craft_button)
	craft_button.position = Vector2(-64, 200)
	side_buttons.append(craft_button)



func init_background() -> void:
	BG = TextureRect.new()
	BG.texture = load("res://models/left_menu.png")
	BG.flip_h = true
	# BG.set_expand_mode(TextureRect.ExpandMode.EXPAND_FIT_HEIGHT)
	BG.size = ENGINE.GameWindow.RIGHT_PANEL_SIZE
	BG.modulate = Constants.COLOR_LIST.pick_random()

	add_child(BG)

func init_title() -> void:
	TITLE = Label.new()
	TITLE.text = "empty"
	# TITLE.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY 
	var parent_width:float = size.x/2
	var child_width:float = TITLE.size.x/2
	var pos:float = parent_width - child_width

	TITLE.position = Vector2(pos, 0)
	# TITLE.position = Vector2(ENGINE.GameWindow.RIGHT_PANEL_SIZE[0]/2, 0)
	TITLE.add_theme_font_size_override("font_size", 32)
	add_child(TITLE)

func init_navigation() -> void:
	BACK_BUTTON = Button.new()
	BACK_BUTTON.text = "< Back"
	BACK_BUTTON.position = Vector2(5,40)
	BACK_BUTTON.focus_mode = FocusMode.FOCUS_NONE
	BACK_BUTTON.connect("pressed", go_back)

	add_child(BACK_BUTTON)


	# NAV_MENU = HFlowContainer.new()
	# NAV_MENU.custom_minimum_size = Vector2(ENGINE.GameWindow.RIGHT_PANEL_SIZE[0], 40)
	# # NAV_MENU.custom_minimum_size = Vector2(290,40)
	# NAV_MENU.position = Vector2(7,47)
	# add_child(NAV_MENU)

func init_entry() -> void:
	SCROLL_CONTAINER = ScrollContainer.new()
	SCROLL_CONTAINER.size = ENGINE.GameWindow.RIGHT_PANEL_SIZE - Vector2(0,90)
	# SCROLL_CONTAINER.size = Vector2(290, 550)
	SCROLL_CONTAINER.position = Vector2(5,90)
	add_child(SCROLL_CONTAINER)

	ENTRY = VBoxContainer.new()
	ENTRY.custom_minimum_size = Vector2(ENGINE.GameWindow.RIGHT_PANEL_SIZE[0],0)
	SCROLL_CONTAINER.add_child(ENTRY)

func init_close_button() -> void:
	CLOSE_BUTTON = Button.new()
	CLOSE_BUTTON.text = "X"
	CLOSE_BUTTON.size = Vector2(30,30)
	
	CLOSE_BUTTON.position = Vector2(ENGINE.GameWindow.RIGHT_PANEL_SIZE[0]-CLOSE_BUTTON.size[0], 0)
	CLOSE_BUTTON.add_theme_font_size_override("font_size", 32)
	CLOSE_BUTTON.connect("pressed", close_menu)
	add_child(CLOSE_BUTTON)

#endregion init

#region building


func add_to_entry(element) -> void:
	ENTRY.add_child(element)

func update_title(title:String) -> void:
	TITLE.text = title
	TITLE.size = TITLE.get_minimum_size()

	var parent_width:float = size[0]/2
	var child_width:float = TITLE.size[0]/2
	var pos:float = parent_width - child_width
	TITLE.position = Vector2(pos, 0)

	
func generate_subnav(nav_list:Array) -> void:
	var subnav:HFlowContainer = HFlowContainer.new()

	for option:String in nav_list:
		var new_button:Button = Button.new()
		new_button.text = option
		new_button.connect("pressed", update_current_entry.bind(CURRENT_ENTRY, option))
		subnav.add_child(new_button)

	ENTRY.add_child(subnav)


func bind_button_to_entry(_button:Button, _entry, _subentry:String="") -> Button:
	# i can't figure out how stupid this is
	_button.connect("pressed", update_current_entry.bind(_entry, _subentry))
	return _button

func bind_button_to_update(_button:Button) -> Button:
	_button.connect("pressed", open_menu)
	return _button

#endregion building

#region update

func clear_bones() -> void:
	for child in ENTRY.get_children():
		child.queue_free()

	#for child in NAV_MENU.get_children():
		#child.queue_free()

func update() -> void:
	clear_bones()
	if len(HISTORY) < 2:
		BACK_BUTTON.set("theme_override_colors/font_color", Color.DARK_GRAY)
	else:
		BACK_BUTTON.set("theme_override_colors/font_color", Color.WHITE)

	if CURRENT_ENTRY == null:
		ENGINE.get_node("Player").populate_journal(self, ENGINE, SUBENTRY)
	else:
		CURRENT_ENTRY.populate_journal(self, ENGINE, SUBENTRY)

func update_window() -> void:
	size = ENGINE.GameWindow.RIGHT_PANEL_SIZE
	position = ENGINE.GameWindow.RIGHT_PANEL_LOCATION

	BG.size = ENGINE.GameWindow.RIGHT_PANEL_SIZE
	var parent_width:float = size.x/2
	var child_width:float = TITLE.size.x/2
	var pos:float = parent_width - child_width
	TITLE.position = Vector2(pos, 0)

	# NAV_MENU.custom_minimum_size = Vector2(ENGINE.GameWindow.RIGHT_PANEL_SIZE[0], 40)
	SCROLL_CONTAINER.size = ENGINE.GameWindow.RIGHT_PANEL_SIZE - Vector2(0,90)
	ENTRY.custom_minimum_size = Vector2(ENGINE.GameWindow.RIGHT_PANEL_SIZE[0], 0)
	CLOSE_BUTTON.position = Vector2(ENGINE.GameWindow.RIGHT_PANEL_SIZE[0]-CLOSE_BUTTON.size[0], 0)
	
	

func update_background_color(color:Color) -> void:
	BG.modulate = color



func update_current_entry(_entry, _subentry:String="") -> void:
	if CURRENT_ENTRY != null and _entry != CURRENT_ENTRY or _subentry != SUBENTRY:
		var current_page = [CURRENT_ENTRY, SUBENTRY]
		HISTORY.append(current_page)
	CURRENT_ENTRY = _entry
	SUBENTRY = _subentry
	# update()
	open_menu()

func go_back() -> void:
	if len(HISTORY) > 0:
		var previous:Array = HISTORY.pop_back()
		CURRENT_ENTRY = previous[0]
		SUBENTRY = previous[1]
	update()


#endregion update


#region utility
func close_menu() -> void:
	position = Vector2(ENGINE.GameWindow.SCREEN_SIZE[0], 0)
	OPEN = false
	HISTORY = []

func open_menu() -> void:
	position = ENGINE.GameWindow.RIGHT_PANEL_LOCATION
	OPEN = true
	update()


#endregion utility
