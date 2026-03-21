extends Control

@export var npc_buttons: PackedScene

var NPC_MENU

signal close_npc_list_signal


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NpcMenu.hide()
	pass



func tick():
	clear_buttons()
	var button_x = 50
	var button_y = 90
	for npc in Global.CURRENT_NPCS:
		var location = Vector2(button_x, button_y)
		var npc_button = npc_buttons.instantiate()
		$NpcList.add_child(npc_button)
		npc_button.initialize(npc)
		npc_button.position = location
		npc_button.connect("pressed", Callable(self, "open_npc_menu").bind(npc_button))
		#npc_button.connect("npc_button_press", Callable(self, "on_npc_button_pressed").bind(npc_button))
		button_y += 40


func clear_buttons():
	for child in $NpcList.get_children():
		if child is NPC_BUTTON:
			child.queue_free()
	if $NpcMenu.visible:
		$NpcMenu.initialize($NpcMenu.DISPLAYED_NPC)
		if $NpcMenu.DISPLAYED_NPC not in Global.CURRENT_NPCS and !$NpcMenu.WATCH:
			$NpcMenu.DISPLAYED_NPC = null
			$NpcMenu.hide()
			$NpcList.show()
			
		
func open_npc_menu(npc_button):
	$NpcList.hide()
	$NpcMenu.initialize(npc_button.DISPLAYED_NPC)
	$NpcMenu.show()
	
func open_npc_menu_via_sprite(npc):
	$NpcList.hide()
	$NpcMenu.initialize(npc)
	$NpcMenu.show()
	
func close_npc_menu():
	$NpcMenu.hide()
	$NpcMenu.WATCH = false
	$NpcList.show()
	SignalBus.npc_hover_off.emit($NpcMenu.DISPLAYED_NPC)


func close_npc_list() -> void:
	close_npc_list_signal.emit()
