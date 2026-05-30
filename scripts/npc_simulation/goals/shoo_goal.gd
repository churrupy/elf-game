class_name ShooGoal extends ACTION

# special version of LeaveRoomAction

var TARGET_ROOM:ROOM
var LEFT_ROOM:bool = false
var WAITED:bool = false #makes them wait a turn to make sure that they don't try to immediately re-enter room

# func _init(engine, owner:NPC) -> void:
# 	ID = "shoo"
# 	ENGINE = engine
# 	OWNER = owner
# 	# since this is added by another person, force-end their current action
# 	OWNER.CURRENT_ACTION = null

func set_target(_room:ROOM) -> ShooGoal:
	TARGET_ROOM = _room
	return self

func set_location() -> ShooGoal:
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

	if TARGET_ROOM == null:
		TARGET_ROOM = ENGINE.Map.get_room(OWNER.LOCATION)

	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if TARGET_ROOM != current_room:
		LEFT_ROOM = true
	else:
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





func run() -> ActionResult:
	print("running: Shoo Action")
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if current_room != TARGET_ROOM:
		if !WAITED:
			var new_action:ACTION = WaitAction.new(ENGINE, OWNER)
			WAITED = true
			return ActionResult.new("action", new_action)
		else:
			return ActionResult.new("end")

	var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_location(LOCATION).calling_action(self)
	return ActionResult.new("action", move_action)
