class_name MoveToTileAction extends ACTION


func run() -> ActionResult:
	if "target_tile" not in OWNER.BLACKBOARD:
		STATUS = "fail"
		return ActionResult.new("end")
	
	# adjust for interaction distance
	var target_tile:TILE = OWNER.BLACKBOARD["target_tile"]
	if target_tile.in_range(OWNER.LOCATION):
		STATUS = "success"
		return ActionResult.new("end")

	var target_location:Vector2 = ENGINE.Map.get_closest_interactable_location(OWNER, target_tile)
	OWNER.BLACKBOARD["target_location"] = target_location
	add_action(MoveAction)
	return ActionResult.new("continue")


func _to_string() -> String:
	var target_tile:TILE = OWNER.BLACKBOARD["target_tile"]
	var str_list:Array[String] = [
		OWNER.NAME,
		"is moving to",
		ENGINE.prettify_vector(target_tile.LOCATION)
	]
	return " ".join(str_list)
