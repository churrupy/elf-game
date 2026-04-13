extends Control

var ENGINE
var CURRENT_ENTRY


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BG.modulate = Constants.COLOR_LIST.pick_random()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update() -> void:
	for child in $ScrollContainer.get_node("Entry").get_children():
		child.queue_free()

	if CURRENT_ENTRY is NPC:
		update_npc()
		

func update_topic(topic) -> void:
	CURRENT_ENTRY = topic
	update()

func update_npc() -> void:
	# standard details
	var npc: NPC = CURRENT_ENTRY
	$Title.text = npc.NAME
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

		var impressions: Array[String] = npc.get_impression(npc_id)
		if len(impressions) > 0:
			var impression_label: RichTextLabel = RichTextLabel.new()
			impression_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			impression_label.fit_content = true
			var _str: String = npc.NAME + " thinks that " + checked_npc.NAME + " is " + ", ".join(impressions) + "."
			impression_label.append_text(_str)
			#impression_label.text = npc.NAME + " thinks that " + checked_npc.NAME + " is " + ", ".join(impressions) + "."
			$ScrollContainer.get_node("Entry").add_child(impression_label)
		
		var rel_details: RichTextLabel = RichTextLabel.new()
		rel_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rel_details.fit_content = true

		for mem: RelationshipMemory in rel_list:
			rel_details.push_list(0, RichTextLabel.ListType.LIST_DOTS, true)
			rel_details.append_text(str(mem))
			rel_details.pop()
		$ScrollContainer.get_node("Entry").add_child(rel_details)


func close_menu() -> void:
	SignalBus.close_journal.emit()
