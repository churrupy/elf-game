class_name LeaveRoomAction extends ACTION

var MOVING_FOR:ACTION
var TARGET_ROOM:ROOM

func _init(engine, owner:NPC) -> void:
	ID = "move"
	ENGINE = engine
	OWNER = owner

func calling_action(moving_for:ACTION) -> LeaveRoomAction:
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	return self

func set_location() -> LeaveRoomAction:
	# builder function
	var this_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if len(this_room.DOOR_LIST) == 0:
		print("NO DOOR ALERT!")
		print("this room is the biggest room on the map so npcs cannot leave it")
		print("CRASH!")
		return self
	var door:DOOR = this_room.DOOR_LIST.pick_random() # this will fuck up if the room exits to two different rooms
	var wall:String = door.wall

	var wall_dict:Dictionary = {
		"up": Vector2.UP,
		"down": Vector2.DOWN,
		"left": Vector2.LEFT,
		"right": Vector2.RIGHT
	}

	var target_direction:Vector2 = door.LOCATION + wall_dict[wall]
	LOCATION = target_direction
	return self



func tick() -> ActionResult:
	var result:ActionResult = run()
	OWNER.decay_needs()
	return result


func run() -> ActionResult:
	if OWNER.LOCATION == LOCATION:
		return ActionResult.new("end")

	var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_location(LOCATION).calling_action(MOVING_FOR)
	return ActionResult.new("add", move_action)
