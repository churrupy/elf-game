extends Node2D

class_name DISPLAYED_NPC

var NPC_OBJECT
var COLOR


func initialize(npc):
	NPC_OBJECT = npc
	$DefaultSprite.modulate = npc.COLOR
	$GlowSprite.modulate = npc.COLOR
	$HoverNameLabel.text = npc.NAME
	#$HoverNameLabel.modulate = COLOR
	#$HoverNameLabel.add_theme_color_override("font_outline_color",Color.BLACK)
	$GlowSprite.hide()
	$HoverNameLabel.hide()
	SignalBus.npc_hover.connect(on_hover)
	SignalBus.npc_hover_off.connect(off_hover)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

	


func on_hover(npc):
	if npc.ID == NPC_OBJECT.ID:
		_on_mouse_entered()
		$DefaultSprite.hide()
		$GlowSprite.show()
		$HoverNameLabel.show()
		
func off_hover(npc):
	if npc.ID == NPC_OBJECT.ID:
		$GlowSprite.hide()
		$DefaultSprite.show()
		$HoverNameLabel.hide()


func sprite_clicked() -> void:
	SignalBus.open_npc_menu.emit(NPC_OBJECT)

func _on_mouse_entered() -> void:
	$DefaultSprite.hide()
	$GlowSprite.show()
	$HoverNameLabel.show()
	#SignalBus.npc_hover.emit(NPC_HOBE)


func _on_mouse_exit() -> void:
	$GlowSprite.hide()
	$DefaultSprite.show()
	$HoverNameLabel.hide()
	#SignalBus.npc_hover_off.emit(self)
