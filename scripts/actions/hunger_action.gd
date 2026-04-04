class_name HungerAction extends ACTION

func _init(engine, owner: NPC, target: TILE) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "snack"
	super._init(engine, owner, target)

func score() -> void:
	# sets ACTION.LOCATION as well
	SCORE += 10 # hunger bonus for urgent needs
	var hunger: int = OWNER.NEEDS["hunger"]
	SCORE += 100 - hunger

	var is_impassable: bool = ENGINE.Map.is_impassable(TARGET.LOCATION)
	var is_reserved: bool = ENGINE.NpcManager.is_reserved(TARGET.LOCATION)
	if is_impassable or is_reserved:
		if !can_do_off_tile: 
			SCORE = -100
			return
		var closest_location: Vector2 = ENGINE.Map.get_closest_adjacent_location(OWNER.LOCATION, TARGET.LOCATION)
		if closest_location == Vector2.INF:
			# no closest location found
			SCORE = -100
			return
		LOCATION = closest_location
	else:
		LOCATION = TARGET.LOCATION

	SCORE -= OWNER.LOCATION.distance_to(LOCATION)


func run() -> Array:
	refresh_needs("hunger")
	#ENGINE.History.add_event(OWNER.ID, "ate", LOCATION)

	chitchat()

	COUNTDOWN -= 1
	if COUNTDOWN < 0:
		return ["end", null]
		
	return ["running", null]
