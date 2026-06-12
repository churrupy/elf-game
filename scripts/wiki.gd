class_name Wiki extends VBoxContainer

var COLOR: Color = Color(1,1,1)

# var PARAGRAPHS:Array[VFlowContainer]
var PARAGRAPHS:Array


func _init() -> void:
	add_newline()

func add_header(_str:String) -> void:
	var new_label:Label = Label.new()
	new_label.text = _str
	new_label.add_theme_font_size_override("font_size", 18)
	new_label.set("theme_override_colors/font_outline_color", Color.WHITE)
	new_label.set("theme_override_constants/outline_size", 2)
	get_children().back().add_child(new_label)
	add_newline()


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

func add_newline() -> void:
	var new_para:HFlowContainer = HFlowContainer.new()
	add_child(new_para)

func add_indented_newline() -> void:
	var new_para:HFlowContainer = HFlowContainer.new()
	var new_label:Label = Label.new()
	new_label.text = "       •"
	new_para.add_child(new_label)
	new_para.position = Vector2(50,0)
	add_child(new_para)


func add_wiki(new_wiki:Wiki) -> void:
	add_child(new_wiki)

func print() -> void:
	var index = 0
	for child in get_children():
		print("para #", index)
		for child2 in child.get_children():
			print(child2)
		index += 1




func update_color(color: Color) -> void:
	COLOR = color
	for child in get_children():
		child.set("theme_override_colors/font_color",color)



func update_current_entry(entry, subentry) -> void:
	print("sending update journal signal: ", entry)
	SignalBus.update_current_entry.emit(entry, subentry)
