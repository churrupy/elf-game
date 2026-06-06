class_name FunGoal extends ACTION

func set_id() -> void:
	ID = "FunAction"


func score() -> FunGoal:
	var need:float = OWNER.NEEDS["fun"] / 100
	SCORE = 1 - (need * need)
	return self

func end_action() -> void:
	CURRENT_ACTION = null

func run() -> ActionResult:
	if OWNER.are_needs_low():
		STATUS = "success"
		return ActionResult.new("end")

	if CURRENT_ACTION == null:
		OWNER.BLACKBOARD["target_need"] = "fun"
		set_current_action(UseTileGoal)
		return ActionResult.new("continue")
	else:
		print(CURRENT_ACTION, CURRENT_ACTION.STATUS)
		STATUS = CURRENT_ACTION.STATUS
		return ActionResult.new("end")


func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is trying to fulfill fun"
	]
	return " ".join(str_list)
