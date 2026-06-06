class_name VibeAction extends ACTION

func score() -> VibeAction:
	SCORE = 0.2
	return self

func run() -> ActionResult:
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	# move to a spot they can idle in
	for i in range(0,5):
		add_action(WaitAction)
	return ActionResult.new("success")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"vibes"
	]
	return " ".join(str_list)