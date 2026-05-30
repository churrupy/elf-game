class_name SocializeAction extends ACTION

# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner
# 	ID = "socialize"
# 	CHATTABLE = true

func score() -> void:
	# social needs
	var need:float = OWNER.NEEDS["social"]/100
	SCORE = 1 - (need * need)


func run() -> ActionResult:
	if OWNER.are_needs_low():
		# right now also catches hunger, but once I add charges i'll update it so that being hungry doens't cancel being in a group
		# because to get to this point if they're hungry they should have an item in their inventory that addresses that issue
		return ActionResult.new("fail")

	#currently assumes that NPC will always want to socialize
	var owner_group:GROUP = ENGINE.GroupManager.get_group(OWNER)
	if owner_group == null:
		add_action(FindGroupAction) # how to handle failing to find a group? just have them swap to some idle or fun action instead
		# i'll figure that out later, i HUNGERRR
		return ActionResult.new("continue")

	var group_location:Vector2 = owner_group.get_location()
	if group_location.distance_to(OWNER.LOCATION) > 1.5:
		ENGINE.NpcManager.remember_location(OWNER, group_location)
		add_action(MoveAction)
		return ActionResult.new("continue")

	ENGINE.History.add_event(self)

	return ActionResult.new("running")

	#if OWNER.are_needs_low():
		#return ActionResult.new("success")
#
	#var owner_group:GROUP = ENGINE.GroupManager.get_group(OWNER)
	#if owner_group == null:
		## var new_action:ACTION = FindGroupAction.new(ENGINE, OWNER).set_goal(self)
		#add_action(FindGroupAction)
		#return ActionResult.new("continue")
#
	#var group_location:Vector2 = owner_group.get_location()
	#if group_location.distance_to(OWNER.LOCATION) > 1.5:
		#ENGINE.NpcManager.remember_location(OWNER, group_location)
		#add_action(MoveAction)
		#return ActionResult.new("continue")
#
#
	#var action_list:Array[GDScript] = [
		#ConverseAction,
		#EatAction
	#]
#
	#ENGINE.History.add_event(self)
	#refresh_needs("social")
	#return ActionResult.new("running")

	# var action_list:Array[GDScript] = [
	# 	ConverseAction,
	# 	JoinGroupAction
	# ]

	# for action_class:GDScript in action_list:
	# 	var new_action:ACTION = action_class.new(ENGINE, OWNER)
	# 	ENGINE.NpcManager.add_action(new_action)

	# return ActionResult.new("continue")

func _to_string() -> String:
	var owner_group:GROUP = ENGINE.GroupManager.get_group(OWNER)
	var str_list:Array[String] = [
		OWNER.NAME,
		"is socializing with",
		str(owner_group)
	]
	return " ".join(str_list)
