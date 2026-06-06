class_name IdleGoal extends ACTION

var ACTION_LIST:Array[ACTION]

func set_id() -> void:
	ID = "IdleAction"

func set_action_list() -> void:
	print("setting action list in IdleAction")
	
	ACTION_LIST = [
		BladderGoal.new(ENGINE, OWNER, self).score(),
		HungerGoal.new(ENGINE, OWNER, self).score(),
		FunGoal.new(ENGINE, OWNER, self).score(),
		SocializeGoal.new(ENGINE, OWNER, self).score(),
	]

	ACTION_LIST.sort_custom(func(a,b): return a.SCORE > b.SCORE)


func run() -> ActionResult:
	if len(ACTION_LIST) == 0:
		set_action_list()
	# success starts over
	# fail moves onto the next one

	for a:ACTION in ACTION_LIST:
		if a.STATUS == "fail": continue
		elif a.STATUS == "success":
			set_action_list()
			return ActionResult.new("continue")
		elif a.STATUS == "running":
			a.add_self_to_owner()
			return ActionResult.new("continue")

	set_action_list()
	return ActionResult.new("continue")

# func run_old() -> ActionResult:
		
# 	var need_list:Array[ACTION] = [
# 		BladderGoal.new(ENGINE, OWNER, self).score(),
# 		HungerGoal.new(ENGINE, OWNER, self).score(),
# 		SocializeGoal.new(ENGINE, OWNER, self).score(),
# 		FunGoal.new(ENGINE, OWNER, self).score()
# 	]

# 	need_list.sort_custom(func(a,b): return a.SCORE > b.SCORE)
# 	for n in need_list:
# 		print(n, n.SCORE)
# 	var chosen_action:ACTION = need_list[0]
# 	# print("action list check: ", need_list)
# 	if chosen_action.SCORE > 0.2:
# 		print("chosen action: ", chosen_action)
# 		print("score: ", chosen_action.SCORE)
# 		chosen_action.add_self_to_owner()
# 		return ActionResult.new("continue")

# 	var nonurgent_list:Array[ACTION] = [
# 		SocializeGoal.new(ENGINE, OWNER, self).score(),
# 		FunGoal.new(ENGINE, OWNER, self).score(),
# 		VibeAction.new(ENGINE, OWNER, self).score()
# 	]


# 	add_action(VibeAction)
# 	add_action(ConsumeAction)

# 	return ActionResult.new("continue")


func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is idling"
	]
	return " ".join(str_list)
