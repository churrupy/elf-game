extends Control

signal auto_tick_signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NpcMenu.hide()
	SignalBus.npc_click.connect(open_npc_menu)
	SignalBus.close_npc_menu.connect(close_npc_menu)
	#$NpcListButton.hide()

	

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

func open_npc_menu(npc):
	print("showing menu")
	$DefaultMenu.hide()
	$NpcMenu.initialize(npc)
	$NpcMenu.show()


func close_npc_menu():
	print("closing menu")
	$NpcMenu.hide()
	$NpcMenu.WATCH = false
	SignalBus.npc_hover_off.emit($NpcMenu.DISPLAYED_NPC)
	$DefaultMenu.show()
	
