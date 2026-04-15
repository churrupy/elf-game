class_name Wiki extends HFlowContainer

var TEMPLATE: String
var COLOR: Color = Color(1,1,1)


func _init(template:String) -> void:
	TEMPLATE = template
	populate()

func populate() -> void:
	var word_list: Array = Array(TEMPLATE.split(" "))
	var new_label: Label = Label.new()
	for word: String in word_list:
		word = word.strip_edges(true,true)
		if "[[" in word: # button
			# reset label
			add_child(new_label)
			new_label = Label.new()
			
			# pull out details
			var word_length: int = len(word) - 4 # 4 char for the [[]]
			word = word.substr(2, word_length)

			var params:Array = word.split(",")
			var new_button: Button = Button.new()

			for p: String in params:
				var key_value: Array = p.split(":")
				var key: String = key_value[0]
				var value: String = key_value[1]

				if key == "COLOR":
					var color_dict: Dictionary = {
						"white": Color.WHITE,
						"red": Color.RED,
						"green": Color.GREEN
					}
					new_button.set("theme_override_colors/font_color",color_dict[value])
					#new_button.font_color = color_dict[value]
				elif key == "NPC":
					var npc: NPC = Global.NPCS[value]
					new_button.text = npc.NAME
					new_button.connect("pressed", update_journal.bind(npc))
				elif key == "TONE":
					new_button.text = value
					new_button.connect("pressed", update_journal.bind(value))
				elif key == "TOPIC":
					new_button.text = value
					new_button.connect("pressed", update_journal.bind(value))
				elif key == "STRING": # for when i don't know what kind of string it is
					new_button.text = value
					new_button.connect("pressed", update_journal.bind(value))
				
			# var button_list: Array = word.split(":")
			# var type: String = button_list[0]
			# var topic: String = button_list[1]
			
			# new_button.text = topic

			# if type == "NPC":
			# 	var npc: NPC = Global.NPCS[topic]
			# 	new_button.connect("pressed", update_journal.bind(npc))
			# else:
			# 	new_button.connect("pressed", update_journal.bind(topic))

			add_child(new_button)
		else:
			new_label.text += " " + word

	add_child(new_label)

func update_color(color: Color) -> void:
	COLOR = color
	for child in get_children():
		child.set("theme_override_colors/font_color",color)


func update_journal(topic):
	SignalBus.update_journal.emit(topic)
