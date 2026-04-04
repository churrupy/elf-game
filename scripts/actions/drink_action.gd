class_name DrinkAction extends ACTION

func _init(engine, owner:NPC, target:TILE) -> void:
	ID = "drink"
	super._init(engine, owner, target)

func score() -> void:
	# sets ACTION.LOCATION as well
	var need: int = OWNER.NEEDS["fun"]
	SCORE += 100 - need

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
	refresh_needs("fun")
	ENGINE.History.add_event(OWNER.ID, "drinks")

	chitchat()

	COUNTDOWN -= 1
	if COUNTDOWN < 0:
		return ["end", null]
	return ["running", null]
