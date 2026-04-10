extends Node

@export var buttons: PackedScene
var ENGINE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.modulate = Constants.COLOR_LIST.pick_random()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update():
	var player_location: Vector2 = ENGINE.get_node("Player").LOCATION
	var location_text: String = "[" + str(int(player_location[0])) + "," + str(int(player_location[1])) + "]"
	$PCLocationLabel.text = location_text
	$TickLabel.text = "T:" + str(Global.TICKS)
	var player_history = ENGINE.History.filter_by_npc("player")
	var player_history_list = ENGINE.History.history_to_string(player_history)
	var trunc_history = player_history_list.slice(-10, -1)
	trunc_history.reverse()
	# clear container
	for child in $PlayerHistoryContainer.get_node("VBoxContainer").get_children():
		child.queue_free()
	for item in trunc_history:
		var new_label = Label.new()
		new_label.text = item
		new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		$PlayerHistoryContainer.get_node("VBoxContainer").add_child(new_label)
	'''
	for child in $NearbyNpcsContainer.get_node("VBoxContainer").get_children():
		child.queue_free()
	for npc_id: String in Global.NEARBY_NPCS:
		var npc: NPC = Global.NPCS[npc_id]
		var npc_button = buttons.instantiate()
		npc_button.initialize(npc)
		$NearbyNpcsContainer.get_node("VBoxContainer").add_child(npc_button)
	'''
			
			
func open_npc_menu(npc):
	SignalBus.npc_click.emit(npc)
	
