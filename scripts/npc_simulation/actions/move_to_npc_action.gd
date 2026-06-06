class_name MoveToNPCAction extends ACTION

var PATH:Pathfinder

func set_id() -> void:
	ID = "MoveToNpcAction"
	
func run() -> ActionResult:
	if "target_npc" not in OWNER.BLACKBOARD:
		STATUS = "fail"
		return ActionResult.new("end")

	var target_npc:NPC = OWNER.BLACKBOARD["target_npc"]
	if target_npc == null:
		STATUS = "fail"
		return ActionResult.new("end")

	if !target_npc.is_available():
		STATUS = "fail"
		return ActionResult.new("end")

	# sure we'll keep all that in for now ^^^
	if OWNER.LOCATION.distance_to(target_npc.LOCATION) <= 1.5:
		STATUS = "success"
		return ActionResult.new("end")

	if PATH == null or target_npc.LOCATION.distance_to(PATH.END) > 1.5:
		print("setting new PATH")
		PATH = Pathfinder.new(ENGINE).set_start(OWNER.LOCATION)
		var closest_interactable:Vector2 = ENGINE.Map.get_closest_interactable_location(OWNER, target_npc)
		PATH.set_end(closest_interactable)
		PATH.find_path()
		
	if !PATH.validate_from_npc(OWNER):
		print("path failed validation")
		STATUS = "fail"
		return ActionResult.new("end")

	var old_location:Vector2 = OWNER.LOCATION
	var next_step:Vector2 = PATH.next_step()
	if next_step.distance_to(old_location) > 1.5:
		print("OWNER pushed too far away from path")
		STATUS = "fail"
		return ActionResult.new("end")
	
	OWNER.LOCATION = next_step
	var new_direction:Vector2 = next_step - old_location
	OWNER.update_direction(new_direction)
	ENGINE.History.create_event(self)

	return ActionResult.new("running")

	

func get_involved_npcs() -> Array[NPC]:
	return [OWNER]

	
func _to_string() -> String:
	var target_npc:NPC = OWNER.BLACKBOARD["target_npc"]
	var str_list:Array[String] = [
		OWNER.NAME,
		"is moving to",
		target_npc.NAME
	]
	return " ".join(str_list)
