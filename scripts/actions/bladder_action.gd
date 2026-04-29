class_name BladderAction extends ACTION

var POSSIBLE:bool = true

enum STATUS {
	RUNNING,
	FAILURE,
	SUCCESS
}

func _init(engine, owner:NPC, target:Node) -> void:
	ENGINE = engine
	OWNER = owner
	TARGET = target
	ID = "use toilet"
	CHATTABLE = false
	LOCATION = target.LOCATION
	print("BLADDER LOCATION", LOCATION)
	#super._init(engine, owner, target)


# func score() -> void:
# 	# sets ACTION.LOCATION as well
# 	SCORE += 10 # bladder bonus for urgent needs
# 	var need: int = OWNER.NEEDS["bladder"]
# 	SCORE += 100 - need



# 	var is_impassable: bool = ENGINE.Map.is_impassable(TARGET.LOCATION)
# 	var is_reserved: bool = ENGINE.NpcManager.is_reserved(TARGET.LOCATION)
# 	if is_impassable or is_reserved:
# 		SCORE = -100
# 		return
# 	LOCATION = TARGET.LOCATION

# 	SCORE -= OWNER.LOCATION.distance_to(LOCATION)

func tick() -> ActionResult:
	return run()

func run() -> ActionResult:
	print("determining")
	var status:STATUS = determine_next_action()
	if status == STATUS.SUCCESS:
		return ActionResult.new("end")
	return ActionResult.new("running")


# func run() -> ActionResult:
# 	var filter:FURNITURE_FILTER = FURNITURE_FILTER.new(ENGINE).set_list().has_tag("fill_bladder").at_location(OWNER.LOCATION)
# 	var toilets:Array[Furniture] = filter.run_filter()
# 	if len(toilets) > 0:
# 		print("toileting")
# 		refresh_needs("bladder")
# 		return ActionResult.new("running")



# 	var filter:FURNITURE_FILTER = FURNITURE_FILTER.new(ENGINE).set_list().in_range_of(OWNER.LOCATION, 20).is_available().has_tag("fill_bladder")
# 	var toilets:Array[Furniture] = filter.run_filter()
# 	if len(toilets) == 0:
# 		print("no toilets for some reason")
# 		return ActionResult.new("running")

# 	filter.at_location()

# 	toilets.sort_custom(func(a,b):OWNER.LOCATION.distance_to(b.LOCATION) < OWNER.LOCATION.distance_to(a.LOCATION))
# 	var chosen_toilet:Furniture = toilets[0]

# 	var new_action:MoveAction = MoveAction.new(ENGINE, OWNER, chosen_toilet, "bladder")
# 	return 


# 	print("toileting")
# 	refresh_needs("bladder")
# 	#ENGINE.History.add_event(OWNER.ID, "toileted")

# 	# update direction facing
# 	# get_neighbors already filters out impassable tiles
# 	# of course doesn't take into consideration impassable tiles that you can see over (eg table) but whatever i'll deal for now
# 	# i guess technically a table wouldn't eventually be impassable, it would just take a long time to get around, but WHATEVER
# 	var neighbors: Array[Vector2] = ENGINE.Map.get_neighbors(OWNER.LOCATION) 


# 	var average_vector: Vector2 = Vector2.ZERO
# 	var wall_counter:int = 0
# 	for v: Vector2 in neighbors:
# 		var direction: Vector2 = v - OWNER.LOCATION
# 		average_vector += direction
# 		wall_counter += 1
		
	
# 	var average_direction: Vector2 = Vector2(average_vector[0]/wall_counter, average_vector[1]/wall_counter)
# 	#print("average_direction ", average_direction)
# 	OWNER.update_direction(average_direction)


# 	if OWNER.NEEDS["bladder"] >= 100:
# 		return ActionResult.new("end", null)
# 		#return ["end", null]
# 	return ActionResult.new("running", null)
# 	#return ["running", null]



func determine_next_action() -> STATUS:
	# sequence
	var node_list: Array[Callable] = [
		go_to_toilet,
		use_toilet
	]

	for node:Callable in node_list:
		var status:STATUS = node.call()
		if status != STATUS.SUCCESS: return status
	return STATUS.SUCCESS

func go_to_toilet() -> STATUS:

	if OWNER.LOCATION == LOCATION:
		return STATUS.SUCCESS
	else:
		var new_action:MoveAction = MoveAction.new(ENGINE, OWNER, TARGET, self)
		new_action.LOCATION = LOCATION
		ENGINE.NpcManager.add_state(new_action)
		return STATUS.RUNNING
	
	# var filter:FURNITURE_FILTER = FURNITURE_FILTER.new(ENGINE).set_list().has_tag("fill_bladder").at_location(OWNER.LOCATION)
	# var toilets:Array[Furniture] = filter.run_filter()
	# if len(toilets) > 0:
	# 	return STATUS.SUCCESS

	# print("moving to toilet")
	# filter = FURNITURE_FILTER.new(ENGINE).set_list().in_range_of(OWNER.LOCATION, 20).is_available().has_tag("fill_bladder")
	# toilets = filter.run_filter()
	# if len(toilets) == 0:
	# 	print("no toilets for some reason")
	# 	return STATUS.FAILURE

	# toilets.sort_custom(func(a,b):OWNER.LOCATION.distance_to(b.LOCATION) < OWNER.LOCATION.distance_to(a.LOCATION))
	# var chosen_toilet:Furniture = toilets[0]
	# print("chosen_toilet", chosen_toilet)


	# var new_action:MoveAction = MoveAction.new(ENGINE, OWNER, chosen_toilet, self)
	# ENGINE.NpcManager.add_state(new_action)
	# return STATUS.RUNNING

func use_toilet() -> STATUS:
	print("toileting")
	refresh_needs("bladder")
	if OWNER.NEEDS["bladder"] >= 100:
		return STATUS.SUCCESS
	return STATUS.RUNNING
