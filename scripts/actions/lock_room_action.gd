class_name LockRoomAction extends ACTION

var MOVING_FOR:ACTION
var PATH: Array[Vector2]
var TARGET_ROOM:ROOM

func _init(engine, owner:NPC) -> void:
	ID = "move"
	ENGINE = engine
	OWNER = owner
	#TARGET_ROOM = target
	#TARGET = target
	#LOCATION = target.LOCATION
	#MOVING_FOR = moving_for
	#CHATTABLE = moving_for.CHATTABLE
	#super._init(engine, owner, target)
	#ENGINE.GroupManager.leave_group(owner)

func room_to_secure(_room:ROOM) -> LockRoomAction:
	TARGET_ROOM = _room
	return self

func calling_action(moving_for:ACTION) -> LockRoomAction:
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	return self

func tick() -> ActionResult:
	var result:ActionResult = run()
	OWNER.decay_needs()
	return result

func run() -> ActionResult:
	for door:DOOR in TARGET_ROOM.DOOR_LIST:
		if door.opened:
			if OWNER.LOCATION == door.LOCATION:
				door.close()
			else:
				#var new_action:MoveAction = MoveAction.new(ENGINE, OWNER, door, self).set_location(door.LOCATION)
				var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(door).calling_action(self)
				return ActionResult.new("add", move_action)
	return ActionResult.new("end")


func _to_string() -> String:
	var str_list:Array[String] = [
		"[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is locking room for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)
