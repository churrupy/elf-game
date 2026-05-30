class_name BladderGoal extends ACTION

# var GOAL_STATUS:String = "running"
# var ACTION_STATUS:String = "running"

# var ON_TOILET:bool = false
# var FULL_BLADDER:bool = false

# func _init(engine, owner:NPC) -> void:
# 	ENGINE = engine
# 	OWNER = owner
# 	ID = "use toilet"
# 	CHATTABLE = false

func score() -> BladderGoal:
	var need:float = OWNER.NEEDS["bladder"]/100
	SCORE = 1 - (need * need * need)
	return self

# func score() -> BladderGoal:
# 	if OWNER.NEEDS["bladder"] < 50:
# 		SCORE = 10 + (100 - OWNER.NEEDS["bladder"])
# 		if OWNER.NEEDS["bladder"] < 20:
# 			SCORE += 20
# 	# SCORE += 100 - OWNER.NEEDS["bladder"]
# 	# if OWNER.NEEDS["bladder"] < 50:
# 	# 	SCORE += 10
	
# 	# print("bladder score: ", SCORE)

# 	return self

	

#endregion builder

func run() -> ActionResult:
	if OWNER.NEEDS["bladder"] >= 95:
		return ActionResult.new("success")
	print("trying to fill Bladder need")
	OWNER.BLACKBOARD["target_need"] = "bladder"
	add_action(UseTileGoal) #right now just assumes that only furniture will be able to fulfill bladder
	return ActionResult.new("continue")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is trying to refresh bladder"
	]
	return " ".join(str_list)


# func enter_state() -> void:
# 	print("entering: BladderGoal")
# 	if OWNER.NEEDS["bladder"] >= 95:
# 		FULL_BLADDER = true
# 		return
# 	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
# 	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag("fill_bladder").is_available().set_location(OWNER.LOCATION)
# 	var toilets:Array[TILE] = filter.run_filter()
# 	if len(toilets) == 1:
# 		ON_TOILET = true

#func run() -> ActionResult:
	#if OWNER.NEEDS["bladder"] >= 90:
		#return ActionResult.new("end")
	#
	#var toilets:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().has_tag("fill_bladder").is_available().set_location(OWNER.LOCATION).run_filter()
	#if len(toilets) == 0:
		#OWNER.BLACKBOARD["location_tag"] = "fill_bladder"
		#toilets.sort_custom(func(a,b): return a.LOCATION.distance_to(OWNER.LOCATION) < b.LOCATION.distance_to(OWNER.LOCATION))
		#OWNER.BLACKBOARD["target_location"] = toilets[0].LOCATION
		#OWNER.BLACKBOARD["secure_room"] = true
		#var new_goal:ACTION = MoveToTileGoal.new(ENGINE, OWNER)
		## if new_goal fails, what's this goal gonna do differently?
		#return ActionResult.new("add", new_goal)
#
	#var new_action:ACTION = PeeAction.new(ENGINE, OWNER)
	#return ActionResult.new("action", new_action)
		# not sitting on tile
	# 	var toilets_in_room:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().has_tag("fill_bladder").set_room(current_room)
	# if FULL_BLADDER:
	# 	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	# 	if current_room.is_secured():
	# 		var new_action:ACTION = UnlockRoomAction.new(ENGINE, OWNER).set_goal(self)
	# 		return ActionResult.new("add", new_action)
	# 	else:
	# 		return ActionResult.new("end")
	# elif ON_TOILET:
	# 	var new_action:ACTION = PeeAction.new(ENGINE, OWNER)
	# 	return ActionResult.new("action", new_action)
	# else:
	# 	# var new_action:ACTION = MoveToToilet.new(ENGINE, OWNER) # goal
	# 	var new_action:ACTION = MoveToTileGoal.new(ENGINE, OWNER).set_tag("fill_bladder").to_secure()
	# 	return ActionResult.new("add", new_action)
