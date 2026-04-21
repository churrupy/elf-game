extends Control

var ENGINE
var CURRENT_ENTRY: String = "All"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Menu.get_node("BG").modulate = Constants.COLOR_LIST.pick_random()
	# SignalBus.toggle_journal.connect(toggle_journal)
	SignalBus.toggle_journal.connect(toggle_journal)
	update()

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update() -> void:
	for child in $Menu.get_node("ScrollContainer").get_node("Entry").get_children():
		child.queue_free()

	for child in $Menu.get_node("Navigation").get_children():
		child.queue_free()

	if CURRENT_ENTRY == "All":
		update_all()
	elif CURRENT_ENTRY == "NPCs":
		update_all_npcs()
	elif CURRENT_ENTRY == "Topics":
		update_all_topics()
	elif CURRENT_ENTRY == "Traits":
		update_all_traits()
	elif CURRENT_ENTRY in Global.NPCS:
		update_npc()
	else:
		update_entry()


func update_all() -> void:
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
		$Menu.get_node("ScrollContainer").get_node("Entry").add_child(new_button)

func update_all_npcs() -> void:
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
		$Menu.get_node("ScrollContainer").get_node("Entry").add_child(new_button)

func update_all_topics() -> void:
	update_title("Topics")

	var nav_list: Array[String] = [
		"All",
	]
	update_navigation(nav_list)


func update_all_traits() -> void:
	update_title("Traits")

	var nav_list: Array[String] = [
		"All",
	]
	update_navigation(nav_list)


func update_entry() -> void:
	update_title(CURRENT_ENTRY.capitalize())

	var nav_list: Array[String] = [
		"All",
		"Topics"
	]
	update_navigation(nav_list)

	var new_label: Label = Label.new()
	new_label.text = "Instert information about this topic here"
	$Menu.get_node("ScrollContainer").get_node("Entry").add_child(new_label)


func update_npc() -> void:
	# standard details
	
	var npc: NPC = Global.NPCS[CURRENT_ENTRY]
	update_title(npc.NAME)

	var nav_list: Array[String] = [
		"All",
		"NPCs"
	]
	update_navigation(nav_list)


	var display_list: Array[String] = [
		"ID: " + npc.ID,
		"Gender: " + npc.GENDER,
	]
	
	for need: String in npc.NEEDS.keys():
		var _str: String = need.capitalize() + ": " + str(int(npc.NEEDS[need]))
		display_list.append(_str)

	for item: String in display_list:
		var new_label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$Menu.get_node("ScrollContainer").get_node("Entry").add_child(new_label)

	#opinions
	for op:String in npc.OPINIONS:
		var new_label = Label.new()
		new_label.text = op + ":" + str(npc.OPINIONS[op])
		$Menu.get_node("ScrollContainer").get_node("Entry").add_child(new_label)

	# relationship details
	# i'll have to rewrite this agaaaaain

	var impression_list: Array[Impression] = npc.get_all_impressions()
	for impression: Impression in impression_list:
		var target: NPC = impression.TARGET
		var npc_button: Button = Button.new()
		npc_button.text = target.ID
		$Menu.get_node("ScrollContainer").get_node("Entry").add_child(npc_button)
		npc_button.connect("pressed", toggle_journal.bind(target.ID))

		var new_wiki: Wiki = impression.to_wiki()
		$Menu.get_node("ScrollContainer").get_node("Entry").add_child(new_wiki)

	# for npc_id: String in npc.RELATIONSHIPS.keys():
	# 	var rel_list: Array = npc.RELATIONSHIPS[npc_id]
	# 	if len(rel_list) == 0: continue

	# 	var checked_npc:NPC = Global.NPCS[npc_id]

	# 	var npc_button: Button = Button.new()
	# 	var rel_score: int = npc.get_opinion(npc_id)
	# 	npc_button.text = npc_id + " [" + str(rel_score) + "]"
	# 	$Menu.get_node("ScrollContainer").get_node("Entry").add_child(npc_button)
	# 	npc_button.connect("pressed", toggle_journal.bind(checked_npc.ID))


	# 	var opinion: String = npc.get_opinion_string(npc_id)
	# 	var opinion_label: Label = Label.new()
	# 	opinion_label.text = npc.NAME + " thinks that " + checked_npc.NAME + " is " + opinion + "."
	# 	opinion_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# 	$Menu.get_node("ScrollContainer").get_node("Entry").add_child(opinion_label)

	# 	var impression_wiki: Wiki = npc.get_impression(checked_npc)
	# 	$Menu.get_node("ScrollContainer").get_node("Entry").add_child(impression_wiki)

func update_title(title:String) -> void:
	$Menu.get_node("Title").text = title

func update_navigation(nav_list: Array[String]) -> void:
	for i in range(0,len(nav_list)):
		var option: String = nav_list[i]
		var nav_button: Button = Button.new()
		nav_button.text = option
		nav_button.connect("pressed", toggle_journal.bind(option))
		$Menu.get_node("Navigation").add_child(nav_button)
		if i != len(nav_list) -1:
			var label: Label = Label.new()
			label.text = " > "
			$Menu.get_node("Navigation").add_child(label)

func toggle_journal(topic: String="") -> void:

	if topic == "" or topic == CURRENT_ENTRY:
		$Menu.visible = !$Menu.visible
	else:
		CURRENT_ENTRY = topic
		$Menu.visible = true

	update()
