class_name MoveToTargetAction extends ACTION

var MOVING_FOR:ACTION
var PATH:Array[Vector2]

func _init(engine, owner:NPC) -> void:
	ID = "move"
	ENGINE = engine
	OWNER = owner
	SEEABLE = true

func set_target(target:Node) -> MoveToTargetAction:
	TARGET = target
	return self

func set_goal(moving_for:ACTION) -> MoveToTargetAction:
	MOVING_FOR = moving_for
	return self

func update_path() -> void:
	LOCATION = TARGET.LOCATION
	PATH = ENGINE.Map.get_pathfind_path(OWNER.LOCATION, TARGET.LOCATION)

func validate_path() -> void:
	# checks that path is still valid

	# target still at location
	if TARGET.LOCATION != LOCATION:
		PATH = []
		return

	# upcoming visible path is still valid
	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list_from_vector(PATH).in_range_of(OWNER.LOCATION, 10).in_arc_of(OWNER.DIRECTION)
	var visible_tile:Array[TILE] = filter.run_filter()
	print("visible tile: ", visible_tile)
	filter = TILE_FILTER.new(ENGINE).set_list(visible_tile).in_range_of(OWNER.LOCATION, 100).is_passable().is_available()
	var passable_tile:Array[TILE] = filter.run_filter()
	print("passable tile: ", passable_tile)
	if len(visible_tile) != len(passable_tile):
		PATH = []
		return

	# owner is still close to next path step
	if PATH.front().distance_to(OWNER.LOCATION) >= 1.5:
		PATH = []
		return
	

func run() -> ActionResult:
	print("moving for", MOVING_FOR)
	if OWNER.LOCATION.distance_to(TARGET.LOCATION) <= 1.5:
		print("reached target")
		return ActionResult.new("end")

	validate_path()

	if len(PATH) == 0:
		update_path()
		if len(PATH) == 0:
			return ActionResult.new("end")

	# move to next step
	var old_location:Vector2 = OWNER.LOCATION
	print("move action PATH: ", PATH)
	var next_step:Vector2 = PATH.pop_front()

	OWNER.LOCATION = next_step
	
	var new_direction:Vector2 = next_step - old_location
	OWNER.update_direction(new_direction)
	# ENGINE.History.add_move_event(OWNER)
	ENGINE.History.create_event(self)
	print("moving from ", old_location, " to ", next_step)

	return ActionResult.new("running")

func get_involved_npcs() -> Array[NPC]:
	return [OWNER]

	
func _to_string() -> String:
	var str_list:Array[String] = [
		# "[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is moving for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)