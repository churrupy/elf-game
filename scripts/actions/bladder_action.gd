class_name BladderAction extends ACTION

var GOAL_STATUS:String = "running"
var ACTION_STATUS:String = "running"

var ON_TOILET:bool = false
var FULL_BLADDER:bool = false

func _init(engine, owner:NPC) -> void:
	ENGINE = engine
	OWNER = owner
	# TARGET = target
	ID = "use toilet"
	CHATTABLE = false
	# find_target()
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

# func validate() -> bool:
# 	if TARGET == null:
# 		VALID = false
# 		return false
# 	return true

func score() -> BladderAction:
	if TARGET == null:
		SCORE = -100

	SCORE += 100 - OWNER.NEEDS["bladder"]
	return self

	

#endregion builder

func validate() -> ActionResult:
	var this_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).has_tag("fill_bladder").set_room(this_room)
	var filtered_tiles: Array[TILE] = filter.run_filter()
	if len(filtered_tiles) == 0:
		# move to room
		pass

	if not this_room.is_secured():
		pass
		#var new_goal:ACTION = LockRoomGoal.new(ENGINE, OWNER) # locks current room
		#return ActionResult.new("add", new_goal)
	
	# check if owner is on a toilet
	var tile:TILE = ENGINE.Map.get_tile(OWNER.LOCATION)
	if "fill_bladder" not in tile.DATA["tags"]:
		var toilet_tile:TILE = filtered_tiles[0]
		var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_target(toilet_tile)
		return ActionResult.new("action", new_action)
	
	var new_action:PeeAction = PeeAction.new(ENGINE, OWNER)
	return ActionResult.new("action", new_action)
	
	# if in same room as toilet
	# should i choose the toilet here??
	# i might have fucked myself with the way i generated rooms lol
	# why do i not have a way to test whether a particular object is in the room lol



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

func enter_state() -> void:
	print("entering: BladderAction")
	if OWNER.NEEDS["bladder"] >= 95:
		FULL_BLADDER = true
		return
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag("fill_bladder").is_available().set_location(OWNER.LOCATION)
	var toilets:Array[TILE] = filter.run_filter()
	if len(toilets) == 1:
		ON_TOILET = true

func run() -> ActionResult:
	if FULL_BLADDER:
		return ActionResult.new("end")
	elif ON_TOILET:
		var new_action:ACTION = PeeAction.new(ENGINE, OWNER)
		return ActionResult.new("action", new_action)
	else:
		var new_action:ACTION = MoveToToilet.new(ENGINE, OWNER) # goal
		return ActionResult.new("add", new_action)

func run_old() -> ActionResult:
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

func populate_stack() -> void:
	# reserve location
	print("Goal: Bladder Action")
	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag("fill_bladder").is_available()
	var toilets:Array[TILE] = filter.run_filter()
	if len(toilets) > 0:
		toilets.sort_custom(func(a,b): OWNER.LOCATION.distance_to(b.LOCATION) < OWNER.LOCATION.distance_to(a.LOCATION))
		TARGET = toilets[0]
		LOCATION = TARGET.LOCATION
	
	else:
		# something else
		pass
	
	var new_action:ACTION = RefreshNeedsAction.new(ENGINE, OWNER).set_need("bladder")
	OWNER.STATE_STACK.append(new_action)

	new_action = MoveAction.new(ENGINE, OWNER).set_target(TARGET).secure_room().calling_action(self)
	OWNER.STATE_STACK.append(new_action)
