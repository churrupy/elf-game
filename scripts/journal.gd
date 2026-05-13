class_name JOURNAL extends Control

var ENGINE
var CURRENT_ENTRY: String = "All"
var SUBENTRY:String = "Needs"

var PINNED_ENTRIES: Array[String]

var BG:TextureRect
var TITLE:Label
var NAV_MENU:HFlowContainer
# var SUBNAV_MENU:HFlowContainer
var SCROLL_CONTAINER:ScrollContainer
var ENTRY:VBoxContainer

var JOURNAL_BUTTON:Button
var CLOSE_BUTTON:Button

var TOGGLEABLE:Array 

#region init


func _init(engine) -> void:
	ENGINE = engine
	set_journal_button()
	set_background()
	set_title()
	set_navigation()
	set_entry()
	set_close_button()

	TOGGLEABLE = [
		BG,
		TITLE,
		NAV_MENU,
		# SUBNAV_MENU,
		SCROLL_CONTAINER,
		ENTRY,
		CLOSE_BUTTON
	]

func set_journal_button() -> void:
	JOURNAL_BUTTON = Button.new()
	JOURNAL_BUTTON.icon = ResourceLoader.load("res://models/journal.png")
	JOURNAL_BUTTON.focus_mode = FocusMode.FOCUS_NONE
	JOURNAL_BUTTON.position = Vector2(250,100)
	JOURNAL_BUTTON.connect("pressed", toggle_journal)
	add_child(JOURNAL_BUTTON)

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

	# SUBNAV_MENU = HFlowContainer.new()
	# SUBNAV_MENU.custom_minimum_size = Vector2(290, 40)
	# SUBNAV_MENU.position = Vector2(7,75)
	# add_child(SUBNAV_MENU)

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
	CLOSE_BUTTON.connect("pressed", toggle_journal)
	add_child(CLOSE_BUTTON)

#endregion init

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# $Menu.get_node("BG").modulate = Constants.COLOR_LIST.pick_random()
	# SignalBus.toggle_journal.connect(toggle_journal)
	SignalBus.toggle_journal.connect(toggle_journal)
	position = Vector2(900,0)
	for t in TOGGLEABLE:
		t.hide()
	update()



# func update_old() -> void:
# 	for child in $Menu.get_node("ScrollContainer").get_node("Entry").get_children():
# 		child.queue_free()

# 	for child in $Menu.get_node("Navigation").get_children():
# 		child.queue_free()

# 	if CURRENT_ENTRY == "All":
# 		update_all()
# 	elif CURRENT_ENTRY == "NPCs":
# 		update_all_npcs()
# 	elif CURRENT_ENTRY == "Topics":
# 		update_all_topics()
# 	elif CURRENT_ENTRY == "Traits":
# 		update_all_traits()
# 	elif CURRENT_ENTRY in Global.NPCS:
# 		update_npc()
# 	else:
# 		update_entry()

#region update

func update() -> void:

	for child in ENTRY.get_children():
		child.queue_free()

	for child in NAV_MENU.get_children():
		child.queue_free()

	# for child in SUBNAV_MENU.get_children():
	# 	child.queue_free()

	if CURRENT_ENTRY in Global.NPCS:
		show_npc()
		return

	var options:Dictionary[String, Callable] = {
		"All": show_homepage,
		"NPCs": show_npc_homepage,
		"Topics": show_topic_homepage,
		"Traits": show_trait_homepage,
	}

	if CURRENT_ENTRY in options.keys():
		options[CURRENT_ENTRY].call()
		return
	
	else:
		show_entry()


func show_homepage() -> void:
	update_title("Journal")

	# entry
	var options: Array[String] = [
		"NPCs",
		"Topics",
		"Traits"
	]

	for o: String in options:
		var new_button: Button = Button.new()
		new_button.text = o
		new_button.connect("pressed", toggle_journal.bind(o))
		ENTRY.add_child(new_button)

func show_npc_homepage() -> void:
	update_title("NPCs")

	var nav_list: Array[String] = [
		"All",
	]
	update_navigation(nav_list)

	for npc_id: String in Global.NPCS.keys():
		var npc: NPC = Global.NPCS[npc_id]
		var new_button: Button = Button.new()
		new_button.text = npc.NAME
		new_button.connect("pressed", toggle_journal.bind(npc.ID))
		ENTRY.add_child(new_button)

func show_topic_homepage() -> void:
	update_title("Topics")

	var nav_list: Array[String] = [
		"All",
	]
	update_navigation(nav_list)


func show_trait_homepage() -> void:
	update_title("Traits")

	var nav_list: Array[String] = [
		"All",
	]
	update_navigation(nav_list)


func show_entry() -> void:
	update_title(CURRENT_ENTRY.capitalize())

	var nav_list: Array[String] = [
		"All",
		"Topics"
	]
	update_navigation(nav_list)

	var new_label: Label = Label.new()
	new_label.text = "Instert information about this topic here"
	ENTRY.add_child(new_label)


#region npc

func show_npc() -> void:
	# standard details
	
	var npc: NPC = Global.NPCS[CURRENT_ENTRY]
	update_title(npc.NAME)

	var nav_list: Array[String] = [
		"All",
		"NPCs"
	]
	# update_navigation(nav_list)

	

	var subnav_options:Dictionary[String, Callable] = {
		"Needs": show_npc_needs,
		"Details": show_npc_details,
		"Relationships": show_npc_relationships,
		"Inventory": show_npc_inventory,
	}

	show_npc_snap(npc, subnav_options.keys())

	# update_npc_subnavmenu(subnav_options.keys())

	subnav_options[SUBENTRY].call(npc)

func show_npc_snap(npc:NPC, subnav_options:Array[String]) -> void:
	var display_list: Array[String] = [
		"ID: " + npc.ID,
		"Gender: " + npc.GENDER,
	]

	for item:String in display_list:
		var new_label:Label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ENTRY.add_child(new_label)

	var subnav_menu:HFlowContainer = HFlowContainer.new()
	ENTRY.add_child(subnav_menu)

	for option:String in subnav_options:
		var nav_button:Button = Button.new()
		nav_button.text = option
		nav_button.connect("pressed", update_subnav.bind(option))
		subnav_menu.add_child(nav_button)


func show_npc_needs(npc:NPC) -> void:

	for need: String in npc.NEEDS.keys():
		var _str: String = need.capitalize() + ": " + str(int(npc.NEEDS[need]))
		var new_label:Label = Label.new()
		new_label.text = _str
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ENTRY.add_child(new_label)


func show_npc_details(npc:NPC) -> void:
	
	for op: String in npc.OPINIONS.keys():
		var _str: String = op.capitalize() + ": " + str(int(npc.OPINIONS[op]))
		var new_label:Label = Label.new()
		new_label.text = _str
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ENTRY.add_child(new_label)


func show_npc_relationships(npc:NPC) -> void:

	# relationship details
	var impression_list: Array[Impression] = npc.get_all_impressions()
	for impression: Impression in impression_list:
		var target: NPC = impression.TARGET
		var npc_button: Button = Button.new()
		npc_button.text = target.ID
		ENTRY.add_child(npc_button)
		npc_button.connect("pressed", toggle_journal.bind(target.ID))

		var new_wiki: Wiki = impression.to_wiki()
		ENTRY.add_child(new_wiki)

func show_npc_inventory(npc:NPC) -> void:

	var inventory:INVENTORY = ENGINE.InventoryManager.get_inventory_of(npc.ID)
	for item:ITEM in inventory.ITEMS:
		var new_label:Label = Label.new()
		new_label.text = item.TYPE
		ENTRY.add_child(new_label)

# func update_title(title:String) -> void:
# 	$Menu.get_node("Title").text = title

#endregion npc

func update_title(title:String) -> void:
	TITLE.text = title

func update_navigation(nav_list:Array[String]) -> void:
	for i in range(0,len(nav_list)):
		var option:String = nav_list[i]
		
		var nav_button:Button = Button.new()
		nav_button.text = option
		nav_button.connect("pressed", toggle_journal.bind(option))
		NAV_MENU.add_child(nav_button)

		if i != len(nav_list) -1:
			var divider:Label = Label.new()
			divider.text = " > "
			NAV_MENU.add_child(divider)

# func update_npc_subnavmenu(subnav_list:Array[String]) -> void:

# 	for option:String in subnav_list:

# 		var nav_button:Button = Button.new()
# 		nav_button.text = option
# 		nav_button.connect("pressed", update_subnav.bind(option))
# 		SUBNAV_MENU.add_child(nav_button)


# func update_navigation(nav_list: Array[String]) -> void:
# 	for i in range(0,len(nav_list)):
# 		var option: String = nav_list[i]
# 		var nav_button: Button = Button.new()
# 		nav_button.text = option
# 		nav_button.connect("pressed", toggle_journal.bind(option))
# 		$Menu.get_node("Navigation").add_child(nav_button)
# 		if i != len(nav_list) -1:
# 			var label: Label = Label.new()
# 			label.text = " > "
# 			$Menu.get_node("Navigation").add_child(label)

func toggle_journal(topic: String="") -> void:
	if topic == "" or topic == CURRENT_ENTRY:
		for t in TOGGLEABLE:
			t.visible = !t.visible
		# $Menu.visible = !$Menu.visible
	else:
		CURRENT_ENTRY = topic
		for t in TOGGLEABLE:
			t.show()
		# $Menu.visible = true

	update()


func update_subnav(option:String) -> void:
	SUBENTRY = option
	update()
