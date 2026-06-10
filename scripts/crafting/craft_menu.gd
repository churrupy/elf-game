class_name CRAFT_MENU extends Control

var ENGINE
var BONES:MENU_BONES
var CURRENT_ENTRY:String = "Cooking"

var COLOR:Color

var PINNED_ENTRIES:Array[String]

var BG:TextureRect
var TITLE:Label
var NAV_MENU:HFlowContainer

var SCROLL_CONTAINER:ScrollContainer
var ENTRY:VBoxContainer

var CRAFT_BUTTON:Button
var CLOSE_BUTTON:Button

var TOGGLEABLE:Array

#region init

func _init(engine, bones:MENU_BONES) -> void:
	ENGINE = engine
	BONES = bones
	COLOR = Constants.COLOR_LIST.pick_random()
	set_craft_button()
	# set_background()
	# set_title()
	# set_navigation()
	# set_entry()
	# set_close_button()

	# TOGGLEABLE = [
	# 	BG,
	# 	TITLE,
	# 	NAV_MENU,
	# 	SCROLL_CONTAINER,
	# 	ENTRY,
	# 	CLOSE_BUTTON
	# ]

func set_craft_button() -> void:
	CRAFT_BUTTON = Button.new()
	CRAFT_BUTTON.text = "Craft"
	CRAFT_BUTTON.focus_mode = FocusMode.FOCUS_NONE
	CRAFT_BUTTON.position = Vector2(250, 150)
	CRAFT_BUTTON.connect("pressed", toggle_menu)
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

func _ready() -> void:
	position = Vector2(900,0)
	for t in TOGGLEABLE:
		t.hide()
	update()

#endregion init


func toggle_menu(topic:String="") -> void:
	if topic == "" or topic == CURRENT_ENTRY:
		for t in TOGGLEABLE:
			t.visible = !t.visible

	else:
		CURRENT_ENTRY = topic
		for t in TOGGLEABLE:
			t.show()

	update()

#region update
func update() -> void:
	BONES.clear_bones()
	BONES.update_background_color(COLOR)

	var options:Dictionary[String, Callable] = {
		# "All": add_homepage,
		"Cooking": show_filtered_recipes,
		"Crafting": show_filtered_recipes
	}

	if CURRENT_ENTRY in options.keys():
		options[CURRENT_ENTRY].call()


func add_homepage() -> void:
	BONES.update_title("All")

	
func show_filtered_recipes() -> void:
	BONES.update_title(CURRENT_ENTRY)

	var nav_list:Array[String] = [
		"All"
	]
	BONES.update_navigation(nav_list, self)

	var recipe_filter:RECIPE_FILTER = RECIPE_FILTER.new(ENGINE).set_crafting_type(CURRENT_ENTRY.to_lower())
	var recipe_list:Array[Dictionary] = recipe_filter.run_filter()

	for r:Dictionary in recipe_list:

		var new_recipe:RECIPE = RECIPE.new(ENGINE, ENGINE.get_node("Player"), r["name"])
		var display_recipe: RichTextLabel = new_recipe.create_display()
		BONES.add_to_entry(display_recipe)
		
		if new_recipe.CRAFTABLE:
			var craft_button:Button = Button.new()
			craft_button.text = new_recipe.DATA["verb"].capitalize() + " " + r["name"].capitalize()
			craft_button.connect("pressed", craft_recipe.bind(new_recipe))
			BONES.add_to_entry(craft_button)







func update_current_entry(_str:String) -> void:
	print("updating current journal entry: ", _str)
	CURRENT_ENTRY = _str
	update()
	BONES.open_menu()



func update_title(title:String) -> void:
	TITLE.text = title


func update_navigation(nav_list:Array[String]) -> void:
	for i in range(0,len(nav_list)):
		var option:String = nav_list[i]
		
		var nav_button:Button = Button.new()
		nav_button.text = option
		nav_button.connect("pressed", toggle_menu.bind(option))
		NAV_MENU.add_child(nav_button)

		if i != len(nav_list) -1:
			var divider:Label = Label.new()
			divider.text = " > "
			NAV_MENU.add_child(divider)


# func update_old() -> void:

# 	for child in ENTRY.get_children():
# 		child.queue_free()

# 	for child in NAV_MENU.get_children():
# 		child.queue_free()

	
# 	var options:Dictionary[String, Callable] = {
# 		"All": show_homepage,
# 		"Cooking": show_cooking_homepage,
# 		"Crafting": show_crafting_homepage
# 	}

# 	if CURRENT_ENTRY in options.keys():
# 		options[CURRENT_ENTRY].call()
# 		return

# 	# else:
# 	# 	show_entry()

func show_homepage() -> void:
	update_title("All")

	var options:Array[String] = [
		"Cooking",
		"Crafting"
	]

	for o:String in options:
		var new_button:Button = Button.new()
		new_button.text = o
		new_button.connect("pressed", toggle_menu.bind(o))
		ENTRY.add_child(new_button)

func show_cooking_homepage() -> void:
	# print("show cooking menu")
	update_title("Cooking")

	var nav_list:Array[String] = [
		"All"
	]
	update_navigation(nav_list)

	var recipe_filter:RECIPE_FILTER = RECIPE_FILTER.new(ENGINE).set_crafting_type("cooking")
	var recipe_list:Array[Dictionary] = recipe_filter.run_filter()

	# print("printing recipes")
	for r:Dictionary in recipe_list:
		# print(r)
		# var new_label:Label = Label.new()
		# new_label.text = r["name"]
		# ENTRY.add_child(new_label)

		var new_recipe:RECIPE = RECIPE.new(ENGINE, ENGINE.get_node("Player"), r["name"])
		var display_recipe: RichTextLabel = new_recipe.create_display()
		ENTRY.add_child(display_recipe)
		
		if new_recipe.CRAFTABLE:
			var craft_button:Button = Button.new()
			craft_button.text = new_recipe.DATA["verb"].capitalize() + " " + r["name"].capitalize()
			# craft_button.text = "Craft " + r["name"]
			craft_button.connect("pressed", craft_recipe.bind(new_recipe))
			ENTRY.add_child(craft_button)
		# print(display_recipe.global_position)
		# ENTRY.add_child(new_recipe.create_display())

	# print(ENTRY.get_children())


func show_crafting_homepage() -> void:
	update_title("Crafting")

	var nav_list:Array[String] = [
		"All"
	]
	update_navigation(nav_list)

	var recipe_filter:RECIPE_FILTER = RECIPE_FILTER.new(ENGINE).set_crafting_type("crafting")
	var recipe_list:Array[Dictionary] = recipe_filter.run_filter()

	for r:Dictionary in recipe_list:
		var new_recipe:RECIPE = RECIPE.new(ENGINE, ENGINE.get_node("Player"), r)
		ENTRY.add_child(new_recipe.to_wiki())

func craft_recipe(recipe:RECIPE) -> void:
	if !recipe.CRAFTABLE: return

	recipe.craft()

	update()



#endregion update
