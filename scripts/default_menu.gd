extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NpcListButton.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func tick():
	$TickLabel.text = "Ticks: " + str(Global.TICKS)
	$PCLocationLabel.text = "Location: [" + str(Global.PLAYER_LOCATION[0]) + ", " + str(Global.PLAYER_LOCATION[1]) + "]"
	# gather npcs at location (whatever location is lol)
	var num_npcs = len(Global.CURRENT_NPCS)
	
	if num_npcs > 0:
		$NpcListButton.text = str(num_npcs) + " People Present"
		$NpcListButton.show()
	else:
		$NpcListButton.hide()
