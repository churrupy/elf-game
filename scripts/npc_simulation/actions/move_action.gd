class_name MoveAction extends ACTION


var PATH:Pathfinder

func set_id() -> void:
	ID = "MoveAction"


func run() -> ActionResult:
	LOCATION = OWNER.BLACKBOARD["target_location"]
	if LOCATION == Vector2.INF:
		print("invalid MoveAction target: ", LOCATION)
		return ActionResult.new("fail")

	if PATH == null:
		PATH = Pathfinder.new(ENGINE).set_start(OWNER.LOCATION).set_end(LOCATION)
		PATH.find_path()
		# print("Pathfinder check: ", PATH)

	# print("moving for", MOVING_FOR)
	if OWNER.LOCATION == LOCATION:
		# print("success check")
		# print("pathfinder:", PATH)
		# print("reached location")
		# print("owner location:", OWNER.LOCATION)
		# print("target location:", LOCATION)
		return ActionResult.new("success")


	if !PATH.validate_from_npc(OWNER):
		print("path failed validation")
		return ActionResult.new("fail")

	print("valid path: ", PATH)

	var old_location:Vector2 = OWNER.LOCATION
	var next_step:Vector2 = PATH.next_step()
	if next_step.distance_to(old_location) > 1.5:
		print("OWNER pushed too far away from path")
		return ActionResult.new("fail")

	OWNER.LOCATION = next_step
	var new_direction:Vector2 = next_step - old_location
	OWNER.update_direction(new_direction)
	# ENGINE.History.add_move_event(OWNER)
	ENGINE.History.create_event(self)
	# print("moving from ", old_location, " to ", next_step)
	# print(PATH)

	return ActionResult.new("running")


func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is moving for",
		GOAL.ID,
		# "PATH:",
		# str(PATH)
	]
	return " ".join(str_list)
