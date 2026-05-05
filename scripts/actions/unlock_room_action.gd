class_name UnlockRoomAction extends ACTION

var MOVING_FOR:ACTION
var PATH: Array[Vector2]
var TARGET_ROOM:ROOM

func _init(engine, owner:NPC, target:ROOM, moving_for:ACTION) -> void:
	ID = "move"
	ENGINE = engine
	OWNER = owner
	TARGET_ROOM = target
	#TARGET = target
	#LOCATION = target.LOCATION
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	#super._init(engine, owner, target)
	#ENGINE.GroupManager.leave_group(owner)

func tick() -> ActionResult:
	var result:ActionResult = run()
	OWNER.decay_needs()
	return result

func run() -> ActionResult:
	for door:DOOR in TARGET_ROOM.DOOR_LIST:
		if !door.opened:
			if OWNER.LOCATION == door.LOCATION:
				door.open()
			else:
				var new_action:MoveAction = MoveAction.new(ENGINE, OWNER, door, self).set_location(door.LOCATION)
				return ActionResult.new("add", new_action)
	return ActionResult.new("end")

func _to_string() -> String:
	var str_list:Array[String] = [
		"[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is unlocking room for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)
