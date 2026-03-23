extends Label

var DISPLAYED_NPC


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func initialize(npc):
	DISPLAYED_NPC = npc
	$NameLabel.text = DISPLAYED_NPC.NAME
	$PortraitColor.modulate = DISPLAYED_NPC.COLOR

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func close_talk_menu() -> void:
	print("talk clicked")
	SignalBus.close_talk_menu.emit()


func close_hover() -> void:
	print("hovering")
	pass # Replace with function body.
