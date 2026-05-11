extends Control

var ENGINE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BG.modulate = Constants.COLOR_LIST.pick_random()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_old() -> void:
	for child in $ScrollContainer.get_node("VBoxContainer").get_children():
		child.queue_free()

	for event:EVENT in ENGINE.History.HISTORY:
		var new_label: Label = Label.new()
		new_label.custom_minimum_size = Vector2(250,0)
		new_label.text = str(event)
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$ScrollContainer.get_node("VBoxContainer").add_child(new_label)

func update() -> void:
	for child in $ScrollContainer.get_node("VBoxContainer").get_children():
		child.queue_free()

	var event_list:Array[String] = ENGINE.History.event_strings()
	for str:String in event_list:
		var new_label:Label = Label.new()
		new_label.custom_minimum_size = Vector2(250,0)
		new_label.text = str
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$ScrollContainer.get_node("VBoxContainer").add_child(new_label)

func toggle_menu() -> void:
	visible = !visible
	update()

func close_menu() -> void:
	visible = false
