class_name CRAFT_MENU extends Control

var ENGINE
var CURRENT_ENTRY:String

var BG:TextureRect
var TITLE:Label
var NAV_MENU:HFlowContainer

var CRAFT_BUTTON:Button
var CLOSE_BUTTON:Button

var TOGGLEABLE:Array

func _init(engine) -> void:
    ENGINE = engine
    set_craft_button()
    set_background()
    set_title()
    set_navigation()
    set_close_button()

    TOGGLEABLE = [
        BG,
        TITLE,
        NAV_MENU,
        CLOSE_BUTTON
    ]

func set_craft_button() -> void:
    CRAFT_BUTTON = Button.new()
    CRAFT_BUTTON.text = "Craft"
    CRAFT_BUTTON.focus_mode = FocusMode.FOCUS_NUN
    CRAFT_BUTTON.position = Vector2(250, 150)
    CRAFT_BUTTON.connect("pressed", toggle_craft_menu)
    add_child(CRAFT_BUTTON)

func set_background() -> void:
	BG = TextureRect.new()
	BG.texture = load("res://models/left_menu.png")
	BG.flip_h = true
	BG.size = Vector2(300,660)
	BG.modulate = Constants.COLOR_LIST.pick_random()
	add_child(BG)

func set_title() -> void:
	TITLE = Label.new()
	TITLE.text = "Home"
	TITLE.size = Vector2(111,45)
	TITLE.position = Vector2(95,0)
	TITLE.add_theme_font_size_override("font_size", 32)
	add_child(TITLE)

func set_navigation() -> void:
	NAV_MENU = HFlowContainer.new()
	NAV_MENU.custom_minimum_size = Vector2(290,40)
	NAV_MENU.position = Vector2(7,47)
	add_child(NAV_MENU)

func set_close_button() -> void:
	CLOSE_BUTTON = Button.new()
	CLOSE_BUTTON.text = "X"
	CLOSE_BUTTON.size = Vector2(30,30)
	CLOSE_BUTTON.position = Vector2(250,0)
	CLOSE_BUTTON.add_theme_font_size_override("font_size", 32)
	CLOSE_BUTTON.connect("pressed", toggle_journal)
	add_child(CLOSE_BUTTON)

func _ready() -> void:
    position = Vector2(900,0)
    for t in TOGGLEABLE:
        t.hide()
    update()

