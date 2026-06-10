class_name Wiki extends VBoxContainer

var COLOR: Color = Color(1,1,1)

# var PARAGRAPHS:Array[VFlowContainer]
var PARAGRAPHS:Array


func _init() -> void:
	add_newline()

func _ready() -> void:
	pass


# func add_to_wiki(string: String, type:String="label", color:Color=Color.WHITE, is_npc:bool=false) -> void:
# 	if type == "label":
# 		var new_label: Label = Label.new()
# 		new_label.text = string
# 		new_label.set("theme_override_colors/font_color",color)
# 		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
# 		add_child(new_label)
# 	elif type == "button":
# 		var new_button: Button = Button.new()
# 		new_button.set("theme_override_colors/font_color", color)
# 		if is_npc:
# 			var npc: NPC = Global.NPCS[string]
# 			new_button.text = npc.NAME
# 			new_button.connect("pressed", toggle_journal.bind(npc.ID))
# 		else:
# 			new_button.text = string
# 			new_button.connect("pressed", toggle_journal.bind(string))
# 		add_child(new_button)

func add_text(_str:String, color:Color=Color.WHITE) -> void:
	var str_list:Array = _str.split(" ")
	for word:String in str_list:
		var new_label:Label = Label.new()
		new_label.text = word
		new_label.set("theme_override_colors/font_color", color)
		# new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		get_children().back().add_child(new_label)
		# PARAGRAPHS.back().append(new_label)

func add_text_bold(_str:String, color:Color=Color.WHITE) -> void:
	var new_label:Label = Label.new()
	new_label.text = _str
	new_label.set("theme_override_colors/font_color", color)
	new_label.set("theme_override_colors/font_outline_color", color)
	new_label.set("theme_override_constants/outline_size", 2)
	get_children().back().add_child(new_label)
	# PARAGRAPHS.back().append(new_label)


func add_button(node:Node, color:Color=Color.WHITE, custom_string:String="",) -> void:
	var new_button:Button = Button.new()
	new_button.set("theme_override_colors/font_color", color)
	new_button.text = custom_string
	new_button.focus_mode = FocusMode.FOCUS_NONE
	if new_button.text == "":
		new_button.text = node.NAME
	new_button.connect("pressed", update_current_entry.bind(node, ""))
	get_children().back().add_child(new_button)
	# PARAGRAPHS.back().append(new_button)

func add_newline() -> void:
	var new_para:HFlowContainer = HFlowContainer.new()
	add_child(new_para)
	# PARAGRAPHS.append([])

func add_indented_newline() -> void:
	var new_para:HFlowContainer = HFlowContainer.new()
	var new_label:Label = Label.new()
	new_label.text = "       •"
	new_para.add_child(new_label)
	new_para.position = Vector2(50,0)
	add_child(new_para)



func print() -> void:
	print("printing wiki")
	var index = 0
	for child in get_children():
		print("para #", index)
		for child2 in child.get_children():
			print(child2)
		index += 1

func add_wiki_to_wiki(new_wiki:Wiki) -> void:
	for child in new_wiki.get_children():
		add_child(child)

func update_color(color: Color) -> void:
	COLOR = color
	for child in get_children():
		child.set("theme_override_colors/font_color",color)


func toggle_journal(topic: String) -> void:
	SignalBus.toggle_journal.emit(topic)

func update_current_entry(entry, subentry) -> void:
	SignalBus.update_current_entry.emit(entry, subentry)
