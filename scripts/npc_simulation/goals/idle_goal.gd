class_name IdleGoal extends ACTION


func _init(engine, owner:NPC) -> void:
	ENGINE = engine
	OWNER = owner
	ID = "idle"
	CHATTABLE = true

func start_state() -> void:
	LOCATION = OWNER.LOCATION

func enter_state() -> void:
	print("entering idle state")

func resume_state() -> void:
	LOCATION = OWNER.LOCATION

func can_do_action() -> bool:
	return true


func run() -> ActionResult:

	var goal_options:Array[ACTION] = [
		BladderGoal.new(ENGINE, OWNER).score(),
		HungerGoal.new(ENGINE, OWNER).score(),
		SocialGoal.new(ENGINE, OWNER).score(),
	]


	goal_options.sort_custom(func(a,b): return a.SCORE > b.SCORE)
	print("goal check", goal_options)

	var new_action:ACTION = goal_options[0]
	return ActionResult.new("add", new_action)

	# var possible_actions:Array[ACTION] = [
	# 	BladderGoal.new(ENGINE,OWNER),
	# 	HungerGoal.new(ENGINE,OWNER),
	# 	SocialAction_new.new(ENGINE, OWNER)
	# ]

	# possible_actions.sort_custom(func(a,b):a.SCORE > b.SCORE)

	# #maybe have some kind of cool-down so they won't attempt to do an action repeatedly if it's not available as an option?

	# return ActionResult.new("add").set_action(possible_actions[0])


	# var result:ActionResult

	# if len(OWNER.ACTION_RESPONSES) > 0:
	# 	var new_action:ACTION = RespondAction.new(ENGINE, OWNER)
	# 	result = ActionResult.new("add", new_action)

	# if OWNER.NEEDS["bladder"] < 50:
	# 	var new_action:ACTION = BladderGoal.new(ENGINE, OWNER)
	# 	result = ActionResult.new("add", new_action)
		
	# elif OWNER.NEEDS["hunger"] < 50:
	# 	var new_action:ACTION = HungerGoal.new(ENGINE, OWNER)
	# 	result = ActionResult.new("add", new_action)
	
	# else:
	# 	var new_action:ACTION = SocialAction_new.new(ENGINE, OWNER)
	# 	result = ActionResult.new("add", new_action)

	# return result

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is idling"
	]
	return " ".join(str_list)
