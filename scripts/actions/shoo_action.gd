class_name ShooAction extends ACTION

# special version of LeaveRoomAction

var TARGET_ROOM:ROOM
var LEFT_ROOM:bool = false

func _init(engine, owner:NPC) -> void:
	ID = "be shooed"
	ENGINE = engine
	OWNER = owner

func set_target(_room:ROOM) -> ShooAction:
	TARGET_ROOM = _room
	return self

func set_location() -> ShooAction:
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

# func tick() -> ActionResult:
# 	var result:ActionResult = run()
# 	return result

func enter_state() -> void:
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if TARGET_ROOM != null:
		if current_room != TARGET_ROOM:
			LEFT_ROOM = true
		else:
			LEFT_ROOM = false
	else:
		TARGET_ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
		if len(TARGET_ROOM.DOOR_LIST) == 0:
			print("No doors in this room/this room is the largest room on the map so npcs cannot leave it")
			LEFT_ROOM = true
			return
	
		var door:DOOR = TARGET_ROOM.DOOR_LIST.pick_random()
		var wall:String = door.wall
		var wall_dict:Dictionary = {
			"up": Vector2.UP,
			"down": Vector2.DOWN,
			"left": Vector2.LEFT,
			"right": Vector2.RIGHT
		}

		var target_direction:Vector2 = door.LOCATION + wall_dict[wall]
		LOCATION = target_direction

# func run() -> ActionResult:
# 	if OWNER.LOCATIOIN == LOCATION:
# 		return ActionResult.new("end")
	
# 	var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_location(LOCATION).set_goal(self)
# 	return ActionResult.new("action", move_action)



func run() -> ActionResult:
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if current_room != TARGET_ROOM:
		return ActionResult.new("end")
		
	if OWNER.LOCATION == LOCATION:
		return ActionResult.new("end")

	var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_location(LOCATION).calling_action(self)
	return ActionResult.new("action", move_action)
