class_name BladderAction extends ACTION

func _init(engine, owner:NPC, target:TILE) -> void:
	ID = "use toilet"
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
	refresh_needs("bladder")
	ENGINE.History.add_event(OWNER.ID, "toileted")

	if OWNER.NEEDS["bladder"] >= 100:
		return ActionResult.new("end", null)
		#return ["end", null]
	return ActionResult.new("running", null)
	#return ["running", null]
