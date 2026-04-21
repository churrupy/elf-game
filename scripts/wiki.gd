class_name Wiki extends HFlowContainer

var TEMPLATE: String
#var TEMPLATE_LIST: Array[WikiBit]
var COLOR: Color = Color(1,1,1)


func _init() -> void:
	pass


func add_to_wiki(string: String, type:String="label", color:Color=Color.WHITE, is_npc:bool=false) -> void:
	if type == "label":
		var new_label: Label = Label.new()
		new_label.text = string
		new_label.set("theme_override_colors/font_color",color)
		add_child(new_label)
	elif type == "button":
		var new_button: Button = Button.new()
		new_button.set("theme_override_colors/font_color", color)
		if is_npc:
			var npc: NPC = Global.NPCS[string]
			new_button.text = npc.NAME
			new_button.connect("pressed", toggle_journal.bind(npc.ID))
		else:
			new_button.text = string
			new_button.connect("pressed", toggle_journal.bind(string))
		add_child(new_button)


func update_color(color: Color) -> void:
	COLOR = color
	for child in get_children():
		child.set("theme_override_colors/font_color",color)


func toggle_journal(topic: String) -> void:
	SignalBus.toggle_journal.emit(topic)
