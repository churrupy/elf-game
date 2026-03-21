extends Control

signal auto_tick_signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$CloseButton.hide()
	$NpcListMenu.hide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func tick():
	$DefaultMenu.tick()
	$NpcListMenu.tick()


func open_npc_list() -> void:
	$DefaultMenu.hide()
	$NpcListMenu.show()

func close_npc_list() -> void:
	$NpcListMenu.hide()
	$DefaultMenu.show()


func auto_tick_button() -> void:
	auto_tick_signal.emit()
