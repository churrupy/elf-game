class_name JoinGroupGoal extends ACTION

var IS_IN_GROUP:bool = false
var NEAR_TARGET:bool = false

var CALLING_GOAL:ACTION

func _init(engine, owner:NPC) -> void:
	ID = "join_group"
	# LOCATION = target.LOCATION
	ENGINE = engine
	OWNER = owner
	# TARGET = target
	CHATTABLE = true

#region builder
func set_goal(_goal:ACTION) -> JoinGroupGoal:
	CALLING_GOAL = _goal
	CHATTABLE = CALLING_GOAL.CHATTABLE
	return self

#endregion builder

# func tick() -> ActionResult:
# 	var result: ActionResult = run()
# 	return result

func enter_state() -> void:
	print("starting state: joinGroupAction")
	if ENGINE.GroupManager.is_conversing(OWNER):
		IS_IN_GROUP = true

	else:
		IS_IN_GROUP = false
		if TARGET != null:
			NEAR_TARGET = OWNER.LOCATION.distance_to(TARGET.LOCATION) <= 1.5


func run() -> ActionResult:
	print("running: JoinGroupAction")
	if IS_IN_GROUP:
		return ActionResult.new("end")

	if TARGET == null:
		var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
		var filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().set_room(current_room).is_available().is_not([OWNER])
		var available_npcs:Array[NPC] = filter.run_filter()
		if len(available_npcs) == 0:
			return ActionResult.new("end") 

		var impressions:Array[Impression] = OWNER.get_all_impressions(available_npcs)
		impressions.sort_custom(func(a,b): return a.SCORE > b.SCORE)
		TARGET = impressions[0].TARGET
		NEAR_TARGET = OWNER.LOCATION.distance_to(TARGET.LOCATION) <= 1.5

		# for imp:Impression in impressions:
		# 	var interactable_location:Vector2 = ENGINE.Map.get_closest_interactable_location(OWNER.LOCATION, imp.TARGET)
		# 	if interactable_location != Vector2.INF:
		# 		TARGET = imp.TARGET	
		# 		NEAR_TARGET = OWNER.LOCATION.distance_to(TARGET.LOCATION) <= 1.5
	else:
		print("target:", TARGET)
		print(TARGET.LOCATION)
		print(OWNER.LOCATION)
		print(TARGET.LOCATION.distance_to(OWNER.LOCATION) <= 1.5)

	if NEAR_TARGET:
		# i should make some kind of flag for when I need to put this in its own action lol
		print("joining group")
		ENGINE.GroupManager.join_npc(OWNER, TARGET)
		return ActionResult.new("end")
	else:
		var new_action:ACTION = MoveToTargetAction.new(ENGINE, OWNER).set_target(TARGET).set_goal(self)
		# var interactable_location:Vector2 = ENGINE.Map.get_closest_interactable_location(OWNER.LOCATION, TARGET)
		# var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_location(interactable_location).set_goal(self)
		return ActionResult.new("action", new_action)

	return ActionResult.new("end")

	# # check if target is still available
	# if !TARGET.is_available():
	# 	print("npc now unavailable")
	# 	return ActionResult.new("end").continuing()
	# # var target_action:ACTION = TARGET.STATE_STACK[-1]
	# # if !target_action.CHATTABLE:
	# # 	print("npc now unavailable")
	# # 	return ActionResult.new("end").continuing()

	# if ENGINE.GroupManager.is_in_same_group(OWNER, TARGET):
	# 	return ActionResult.new("end").continuing()

	# if OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
	# 	var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(TARGET).calling_action(self)
	# 	LOCATION = move_action.LOCATION
	# 	return ActionResult.new("add", move_action).continuing()
	# else:
	# 	ENGINE.GroupManager.join_npc(OWNER, TARGET)
	# 	ENGINE.History.create_event(self)
	# 	return ActionResult.new("end")


func _to_string() -> String:
	if TARGET != null:
		var str_list:Array[String] = [
			OWNER.NAME,
			"is joining the group of",
			TARGET.NAME,
		]
		return " ".join(str_list)
	else:
		var str_list:Array[String] = [
			OWNER.NAME,
			"is looking for a group to join"
		]
		return " ".join(str_list)

# func get_involved_npcs() -> Array[NPC]:
# 	var npc_list:Array[NPC] = ENGINE.GroupManager.get_group_participants(OWNER)
# 	return npc_list

# func is_equal(_event:EVENT_new) -> bool:
# 	return false # not an ongoing event, no need to extend timestamps

# func get_role(npc:NPC) -> String:
# 	if npc == OWNER:
# 		return "participant"
# 	else:
# 		return "witness"
