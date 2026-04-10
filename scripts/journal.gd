extends Node

var CURRENT_ENTRY


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update() -> void:
	for child in $Entry.get_children():
		child.queue_free()
		
	var display_list: Array[String] = CURRENT_ENTRY.get_journal_entry()
	for item:String in display_list:
		print(item)
		var new_label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$Entry.add_child(new_label)

func update_topic(topic) -> void:
	CURRENT_ENTRY = topic
	update()


func close_menu() -> void:
	SignalBus.close_journal.emit()
