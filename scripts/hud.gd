extends Control

signal auto_tick_signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func tick():
	$DefaultMenu.tick()


func open_npc_list() -> void:
	$DefaultMenu.hide()

func close_npc_list() -> void:
	#$NpcListMenu.hide()
	pass


func auto_tick_button() -> void:
	auto_tick_signal.emit()
