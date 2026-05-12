class_name BladderAction extends ACTION

enum STATUS {
	RUNNING,
	FAILURE,
	SUCCESS
}

func _init(engine, owner:NPC) -> void:
	ENGINE = engine
	OWNER = owner
	# TARGET = target
	ID = "use toilet"
	CHATTABLE = false
	# LOCATION = target.LOCATION
	# print("BLADDER LOCATION", LOCATION)

#region builder
func set_target(target:Node) -> BladderAction:
	TARGET = target
	LOCATION = target.LOCATION
	return self

func find_target() -> BladderAction:
	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag("fill_bladder").is_available()
	var toilets:Array[TILE] = filter.run_filter()
	if len(toilets) > 0:
		toilets.sort_custom(func(a,b): OWNER.LOCATION.distance_to(b.LOCATION) < OWNER.LOCATION.distance_to(a.LOCATION))
		TARGET = toilets[0]
		LOCATION = TARGET.LOCATION
	return self

#endregion builder


# func run_new() -> ActionResult:
# 	if OWNER.NEEDS["bladder"] > 50:
# 		return ActionResult.new("end")
	
# 	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag("fill_bladder").is_available()
# 	var toilets:Array[TILE] = filter.run_filter()
# 	if len(toilets) == 0:
# 		return ActionResult.new("end")
	
# 	toilets.sort_custom(func(a,b): OWNER.LOCATION.distance_to(b.LOCATION) < OWNER.LOCATION.distance_to(a.LOCATION))
# 	TARGET = toilets[0]
# 	LOCATION = TARGET.LOCATION

# 	var new_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(TARGET).calling_action(self).secure_room()
# 	action_result.ACTION_STACK.append(new_action)

# 	# set up action stack
# 	# move to room
# 	var action_result:ActionResult = ActionResult.new("running")
# 	var target_room:ROOM = ENGINE.Map.get_room(LOCATION)
# 	var new_action:ACTION = MoveToRoomAction.new(ENGINE, OWNER).set_target(target_room)
# 	action_result.ACTION_STACK.append(new_action)

# 	# lock room
# 	new_action = LockRoomAction.new(ENGINE, OWNER).room_to_secure(target_room)
# 	action_result.ACTION_STACK.append(new_action)

# 	# move to toilet
# 	new_action = MoveAction.new(ENGINE, OWNER).set_target(TARGET)
# 	action_result.ACTION_STACK.append(new_action)

# 	new_action = PeeAction.new(ENGINE, OWNER)
# 	action_result.ACTION_STACK.append(new_action)

# 	new_action = UnlockRoomAction.new(ENGINE, OWNER).room_to_unlock(target_room)
# 	action_result.ACTION_STACK.append(new_action)

# 	return action_result

	# will either have to push front, or when adding to the npc stack then invert or something so they go on in the right order


func tick() -> ActionResult:
	return run()


func run() -> ActionResult:
	if TARGET == null or LOCATION == Vector2.INF: return ActionResult.new("end").continuing()
	if OWNER.NEEDS["bladder"] >= 95: return ActionResult.new("end").continuing()

	var npc_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if OWNER.NEEDS["bladder"] >= 95:
		if !npc_room.is_secured():
			return ActionResult.new("end").continuing()
		else:
			var new_action:UnlockRoomAction = UnlockRoomAction.new(ENGINE, OWNER).room_to_unlock(npc_room).calling_action(self)
			return ActionResult.new("replace", new_action)
	else:
		if OWNER.LOCATION == LOCATION:
			# update direction
			# i deleted the logic for this so i'll have to figure it out again *cry*
			refresh_needs("bladder")
			return ActionResult.new("running")
		else:
			var new_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(TARGET).calling_action(self).secure_room()
			return ActionResult.new("add", new_action)
