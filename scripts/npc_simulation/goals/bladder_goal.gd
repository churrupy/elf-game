class_name BladderGoal extends ACTION

func set_id() -> void:
	ID = "BladderAction"

func score() -> BladderGoal:
	var need:float = OWNER.NEEDS["bladder"]/100
	SCORE = 1 - (need * need * need)
	return self

func start_action() -> void:
	ENGINE.GroupManager.leave_group(OWNER)

func end_action() -> void:
	CURRENT_ACTION = null

#endregion builder

func run() -> ActionResult:
	if OWNER.NEEDS["bladder"] >= 95:
		print("bladder refresh success")
		STATUS = "success"
		return ActionResult.new("end")


	if CURRENT_ACTION == null:
		OWNER.BLACKBOARD["target_need"] = "bladder"
		set_current_action(UseTileGoal)
		return ActionResult.new("continue")

	else:
		print(CURRENT_ACTION, CURRENT_ACTION.STATUS)
		STATUS = CURRENT_ACTION.STATUS
		return ActionResult.new("end")
	

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is trying to refresh bladder"
	]
	return " ".join(str_list)
