class_name MoveAction extends ACTION

var MOVING_FOR:ACTION
# var PATH: Array[Vector2]
var PATH:Pathfinder

var secure:bool = false
var room_to_secure:ROOM
var ACTION_GROUP:GROUP
var RANGE:float = 0


# func _init(engine, owner:NPC) -> void:
# 	ID = "move"
# 	ENGINE = engine
# 	OWNER = owner
# 	SEEABLE = true

#region builder
# func set_target(target:Node) -> MoveAction:
# 	TARGET = target
# 	# print(TARGET)
# 	update_location()
# 	return self

# func calling_action(moving_for:ACTION) -> MoveAction:
# 	MOVING_FOR = moving_for
# 	CHATTABLE = moving_for.CHATTABLE
# 	return self

func set_goal(moving_for:ACTION) -> MoveAction:
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	return self

func set_location(loc:Vector2) -> MoveAction:
	# for if there's no set target
	LOCATION = loc
	update_path()
	return self


# func set_group(_group:GROUP) -> MoveAction:
# 	ACTION_GROUP = _group
# 	return self

#endregion builder



func update_path() -> void:
	PATH = Pathfinder.new(ENGINE).set_start(OWNER.LOCATION).set_end(LOCATION)
	PATH.find_path()
	print("Pathfinder check: ", PATH)


func run() -> ActionResult:
	LOCATION = OWNER.BLACKBOARD["saved_loc"]
	if LOCATION == Vector2.INF:
		print("invalid MoveAction target: ", LOCATION)
		return ActionResult.new("fail")

	if PATH == null:
		PATH = Pathfinder.new(ENGINE).set_start(OWNER.LOCATION).set_end(LOCATION)
		PATH.find_path()
		print("Pathfinder check: ", PATH)

	print("moving for", MOVING_FOR)
	if OWNER.LOCATION == LOCATION:
		print("success check")
		print("pathfinder:", PATH)
		print("reached location")
		print("owner location:", OWNER.LOCATION)
		print("target location:", LOCATION)
		return ActionResult.new("success")


	if !PATH.validate_from_npc(OWNER):
		print("path failed validation")
		return ActionResult.new("fail")

	var old_location:Vector2 = OWNER.LOCATION
	var next_step:Vector2 = PATH.next_step()
	if next_step.distance_to(old_location) > 1.5:
		print("OWNER pushed too far away from path")
		return ActionResult.new("fail")

	OWNER.LOCATION = next_step
	var new_direction:Vector2 = next_step - old_location
	OWNER.update_direction(new_direction)
	# ENGINE.History.add_move_event(OWNER)
	ENGINE.History.create_event(self)
	# print("moving from ", old_location, " to ", next_step)
	# print(PATH)

	return ActionResult.new("running")


func _to_string() -> String:
	var str_list:Array[String] = [
		# "[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is moving",
		str(PATH)
		#MOVING_FOR.ID
	]
	return " ".join(str_list)

func get_involved_npcs() -> Array[NPC]:
	return [OWNER]

func get_room() -> ROOM:
	var room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	return room


func is_equal(_event:EVENT_new) -> bool:
	var other_action:ACTION = _event.EVENT_ACTION
	if other_action is not MoveAction: return false
	if other_action.OWNER != OWNER: return false
	var current_room:ROOM = get_room()
	if _event.EVENT_ROOM != current_room: return false

	# if it's been long enough since event happened for action to be processed as a new action
	var tick_range:int = 100
	if _event.END_TICK + tick_range < Global.TICKS:
		return false

	return true

func get_role(npc:NPC) -> String:
	if npc == OWNER:
		return "participant"
	else:
		return "witness"
