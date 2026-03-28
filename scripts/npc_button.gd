extends Button

class_name NPC_BUTTON

var DISPLAYED_NPC


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.npc_hover.connect(on_hover)
	
func on_hover(npc):
	if npc == DISPLAYED_NPC:
		pass
	
func initialize(npc):
	DISPLAYED_NPC = npc
	text = npc.NAME



func _on_mouse_entered() -> void:
	SignalBus.npc_hover.emit(DISPLAYED_NPC)
	#pass # Replace with function body.


func _on_mouse_exit() -> void:
	SignalBus.npc_hover_off.emit(DISPLAYED_NPC)


func _on_pressed() -> void:
	SignalBus.open_npc_menu.emit(DISPLAYED_NPC)
