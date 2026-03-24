extends Node

@export var buttons: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_history_and_tick(history_list):
	var trunc_history = history_list.slice(-5, -1)
	var history_string = "\n".join(trunc_history)
	$PlayerHistory.text = history_string
	tick()


func tick():
	$TickLabel.text = "Ticks: " + str(Global.TICKS)
	$PCLocationLabel.text = "Location: [" + str(Global.PLAYER_LOCATION[0]) + ", " + str(Global.PLAYER_LOCATION[1]) + "]"
	# gather npcs at location (whatever location is lol)

	clear_buttons()
	var button_x = 30
	var button_y = 200
	for npc in Global.CURRENT_NPCS:
		var npc_button = buttons.instantiate()
		add_child(npc_button)
		npc_button.initialize(npc)
		npc_button.position = Vector2(button_x, button_y)
		npc_button.connect("pressed", Callable(self, "open_npc_menu").bind(npc))
		button_y += 40


func clear_buttons():
	for child in get_children():
		if child is NPC_BUTTON:
			child.queue_free()
			
			
func open_npc_menu(npc):
	SignalBus.npc_click.emit(npc)
	
