extends Control

var ENGINE
var CURRENT_ENTRY = "All"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BG.modulate = Constants.COLOR_LIST.pick_random()
	update()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update() -> void:
	for child in $ScrollContainer.get_node("Entry").get_children():
		child.queue_free()

	for child in $Navigation.get_children():
		child.queue_free()

	if CURRENT_ENTRY is String:
		if CURRENT_ENTRY == "All":
			update_all()
		elif CURRENT_ENTRY == "NPCs":
			update_all_npcs()
		elif CURRENT_ENTRY == "Topics":
			update_all_topics()
		elif CURRENT_ENTRY == "Traits":
			update_all_traits()
	elif CURRENT_ENTRY is NPC:
		update_npc()
		

func update_topic(topic) -> void:
	CURRENT_ENTRY = topic
	update()

func update_all() -> void:
	$Title.text = "Journal"

	# navigation
	# no navigation in update_all


	# entry
	var options: Array[String] = [
		"NPCs",
		"Topics",
		"Traits"
	]

	for o: String in options:
		var new_button: Button = Button.new()
		new_button.text = o
		new_button.connect("pressed", update_topic.bind(o))
		$ScrollContainer.get_node("Entry").add_child(new_button)

func update_all_npcs() -> void:
	$Title.text = "NPCs"

	# navigation
	var options: Array[String] = [
		"All",
	]

	for i in range(0,len(options)):
		var option: String = options[i]
		var nav_button: Button = Button.new()
		nav_button.text = option
		nav_button.connect("pressed", update_topic.bind(option))
		$Navigation.add_child(nav_button)
		if i != len(options) -1:
			var label: Label = Label.new()
			label.text = " > "
			$Navigation.add_child(label)

	for npc_id: String in Global.NPCS.keys():
		var npc: NPC = Global.NPCS[npc_id]
		var new_button: Button = Button.new()
		new_button.text = npc.NAME
		new_button.connect("pressed", update_topic.bind(npc))
		$ScrollContainer.get_node("Entry").add_child(new_button)

func update_all_topics() -> void:
	$Title.text = "Topics"

	var options: Array[String] = [
		"All",
	]

	for i in range(0,len(options)):
		var option: String = options[i]
		var nav_button: Button = Button.new()
		nav_button.text = option
		nav_button.connect("pressed", update_topic.bind(option))
		$Navigation.add_child(nav_button)
		if i != len(options) -1:
			var label: Label = Label.new()
			label.text = " > "
			$Navigation.add_child(label)

func update_all_traits() -> void:
	$Title.text = "Traits"

	var options: Array[String] = [
		"All",
	]

	for i in range(0,len(options)):
		var option: String = options[i]
		var nav_button: Button = Button.new()
		nav_button.text = option
		nav_button.connect("pressed", update_topic.bind(option))
		$Navigation.add_child(nav_button)
		if i != len(options) -1:
			var label: Label = Label.new()
			label.text = " > "
			$Navigation.add_child(label)


func update_npc() -> void:
	# standard details
	var npc: NPC = CURRENT_ENTRY
	$Title.text = npc.NAME

	var options: Array[String] = [
		"All",
		"NPCs"
	]

	for i in range(0,len(options)):
		var option: String = options[i]
		var nav_button: Button = Button.new()
		nav_button.text = option
		nav_button.connect("pressed", update_topic.bind(option))
		$Navigation.add_child(nav_button)
		if i != len(options) -1:
			var label: Label = Label.new()
			label.text = " > "
			$Navigation.add_child(label)

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
		$ScrollContainer.get_node("Entry").add_child(new_label)

	#opinions
	for op:String in npc.OPINIONS:
		var new_label = Label.new()
		new_label.text = op + ":" + str(npc.OPINIONS[op])
		$ScrollContainer.get_node("Entry").add_child(new_label)

	# relationship details
	for npc_id: String in npc.RELATIONSHIPS.keys():
		var rel_list: Array = npc.RELATIONSHIPS[npc_id]
		if len(rel_list) == 0: continue

		var checked_npc:NPC = Global.NPCS[npc_id]

		var npc_button: Button = Button.new()
		var rel_score: int = npc.get_opinion(npc_id)
		npc_button.text = npc_id + " [" + str(rel_score) + "]"
		$ScrollContainer.get_node("Entry").add_child(npc_button)
		npc_button.connect("pressed", update_topic.bind(checked_npc))


		var opinion: String = npc.get_opinion_string(npc_id)
		var opinion_label: Label = Label.new()
		opinion_label.text = npc.NAME + " thinks that " + checked_npc.NAME + " is " + opinion + "."
		opinion_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$ScrollContainer.get_node("Entry").add_child(opinion_label)

		var impression_wiki: Wiki = npc.get_impression(checked_npc)
		$ScrollContainer.get_node("Entry").add_child(impression_wiki)

		# var impressions: Array[String] = npc.get_impression(npc_id)
		# if len(impressions) > 0:
		# 	var impression_label: RichTextLabel = RichTextLabel.new()
		# 	impression_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		# 	impression_label.fit_content = true
		# 	var _str: String = npc.NAME + " thinks that " + checked_npc.NAME + " is " + ", ".join(impressions) + "."
		# 	impression_label.append_text(_str)
		# 	#impression_label.text = npc.NAME + " thinks that " + checked_npc.NAME + " is " + ", ".join(impressions) + "."
		# 	$ScrollContainer.get_node("Entry").add_child(impression_label)


func close_menu() -> void:
	SignalBus.close_journal.emit()
