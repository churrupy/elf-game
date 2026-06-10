class_name ITEM extends Node2D

var ID: String
var TYPE: String
var NAME: String
var TAGS: Array[String]
var DATA: Dictionary

func _init(type:String) -> void:
	ID = type + str(Global.get_counter())
	TYPE = type
	NAME = type
	DATA = Constants.ITEM_TEMPLATES[TYPE]
	TAGS.assign(DATA["tags"])

func has_tag(tag:String) -> bool:
	return tag in TAGS

func create_display(amount:int = 1) -> RichTextLabel:
	# print("creating item display")

	var display:RichTextLabel = RichTextLabel.new()
	display.fit_content = true

	display.push_paragraph(HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT)
	display.push_bold()
	display.add_text(NAME.capitalize())
	display.pop()
	if amount > 1:
		display.add_text(" (x" + str(amount) + ")")
	display.pop()

	display.push_paragraph(HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT)
	display.add_text(Constants.ITEM_TEMPLATES[NAME]["description"])
	display.pop()

	return display

func populate_journal(menu, engine, _subentry) -> void:
	menu.update_title(TYPE.capitalize())

	var description:Label = Label.new()
	description.text = Constants.ITEM_TEMPLATES[NAME]["description"]
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu.add_to_entry(description)


func _to_string() -> String:
	return NAME


func is_equal(other_item:ITEM) -> bool:
	if TYPE != other_item.TYPE: return false
	return true
