class_name ConverseAction extends ACTION

func set_id() -> void:
	ID = "ConverseAction"


func run() -> ActionResult:

	if OWNER.are_needs_low():
		STATUS = "success"
		return ActionResult.new("end")

	var owner_group:GROUP = ENGINE.GroupManager.get_group(OWNER)

	if owner_group == null:
		STATUS = "fail"
		return ActionResult.new("end")

	var converse_list = [
		IntroduceAction.new(ENGINE, OWNER, self).score(),
		ChitChatAction.new(ENGINE, OWNER, self).score()
	]

	converse_list.sort_custom(func(a,b): return a.SCORE > b.SCORE)

	var chosen_action:ACTION = converse_list[0]
	chosen_action.add_self_to_owner()

	return ActionResult.new("continue")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is conversing."
	]
	return " ".join(str_list)