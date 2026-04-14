class_name BladderAction extends ACTION

func _init(engine, owner:NPC, target:TILE) -> void:
	ID = "use toilet"
	CHATTABLE = false
	super._init(engine, owner, target)

func score() -> void:
	# sets ACTION.LOCATION as well
	SCORE += 10 # bladder bonus for urgent needs
	var need: int = OWNER.NEEDS["bladder"]
	SCORE += 100 - need



	var is_impassable: bool = ENGINE.Map.is_impassable(TARGET.LOCATION)
	var is_reserved: bool = ENGINE.NpcManager.is_reserved(TARGET.LOCATION)
	if is_impassable or is_reserved:
		SCORE = -100
		return
	LOCATION = TARGET.LOCATION

	SCORE -= OWNER.LOCATION.distance_to(LOCATION)


func run() -> ActionResult:
	print("toileting")
	refresh_needs("bladder")
	#ENGINE.History.add_event(OWNER.ID, "toileted")

	# update direction facing
	# get_neighbors already filters out impassable tiles
	# of course doesn't take into consideration impassable tiles that you can see over (eg table) but whatever i'll deal for now
	# i guess technically a table wouldn't eventually be impassable, it would just take a long time to get around, but WHATEVER
	var neighbors: Array[Vector2] = ENGINE.Map.get_neighbors(OWNER.LOCATION) 


	var average_vector: Vector2 = Vector2.ZERO
	var wall_counter:int = 0
	for v: Vector2 in neighbors:
		var direction: Vector2 = v - OWNER.LOCATION
		average_vector += direction
		wall_counter += 1
		
	
	var average_direction: Vector2 = Vector2(average_vector[0]/wall_counter, average_vector[1]/wall_counter)
	#print("average_direction ", average_direction)
	OWNER.update_direction(average_direction)


	if OWNER.NEEDS["bladder"] >= 100:
		return ActionResult.new("end", null)
		#return ["end", null]
	return ActionResult.new("running", null)
	#return ["running", null]
