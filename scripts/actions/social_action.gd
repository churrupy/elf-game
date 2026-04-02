class_name SocialAction extends ACTION

func _init(engine, owner: NPC, target: NPC) -> void:
	# i hope this works lol
	# no scoring needed for this
	ID = "converse"
	super._init(engine, owner, target)

func can_do_action():
	return ENGINE.NpcManager.is_available(TARGET)

func score() -> void:
	# score based on need
	var need: int = OWNER.NEEDS["social"]
	SCORE += 100 - need

	# score based on preference
	if OWNER == TARGET:
		SCORE = -100
		return
	SCORE += get_opinion()

	var closest_location: Vector2 = ENGINE.Map.get_closest_adjacent_location(OWNER.LOCATION, TARGET.LOCATION)
	if closest_location == Vector2.INF:
		SCORE = -100
		return
	LOCATION = closest_location

func tick() -> Array:
	if !can_do_action():
		return ["end", null]
	if OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
		var new_action: ACTION = ChangingMoveAction.new(ENGINE, OWNER, TARGET, ID)
		return ["add", new_action]
	var result: Array = run()
	OWNER.decay_needs()
	return result

func run() -> Array:
	chitchat() # refresh needs already covered in this
	# have some kind of "if attracted to, then flirt" here

	COUNTDOWN -= 1
	if COUNTDOWN < 0 or !ENGINE.NpcManager.is_available(TARGET):
		return ["end", null]
	return ["running", null]
