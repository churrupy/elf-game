class_name SocializeGoal extends ACTION



func set_id() -> void:
	ID = "SocializeAction"

func score() -> SocializeGoal:
	SCORE = 0.5
	return self
	


func run() -> ActionResult:
	if CURRENT_ACTION != null:
		if CURRENT_ACTION.STATUS == "fail":
			STATUS = "fail"
			return ActionResult.new("end")
			
	if OWNER.are_needs_low():
		# right now also catches hunger, but once I add charges i'll update it so that being hungry doens't cancel being in a group
		# because to get to this point if they're hungry they should have an item in their inventory that addresses that issue
		STATUS = "success"
		return ActionResult.new("end")

	#currently assumes that NPC will always want to socialize
	var owner_group:GROUP = ENGINE.GroupManager.get_group(OWNER)
	if owner_group == null:
		set_current_action(FindGroupAction) # how to handle failing to find a group? just have them swap to some idle or fun action instead
		# i'll figure that out later, i HUNGERRR
		return ActionResult.new("continue")

	# re-orient to group if it has drifted (for whatever reason)
	var group_location:Vector2 = owner_group.get_location()
	if group_location.distance_to(OWNER.LOCATION) > 1.5:
		OWNER.BLACKBOARD["target_location"] = group_location
		set_current_action(MoveAction)
		return ActionResult.new("continue")


	OWNER.look_at(group_location)
	ENGINE.History.add_event(self)

	return ActionResult.new("running")


func _to_string() -> String:
	var owner_group:GROUP = ENGINE.GroupManager.get_group(OWNER)
	var str_list:Array[String] = [
		OWNER.NAME,
		"is socializing with",
		str(owner_group)
	]
	return " ".join(str_list)
