extends Node

var CURRENT_ENTRY


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update() -> void:
	pass

func update_topic(topic) -> void:
	CURRENT_ENTRY = topic


func close_menu() -> void:
	SignalBus.close_journal.emit()
