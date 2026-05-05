class_name BladderAction extends ACTION

var POSSIBLE:bool = true

enum STATUS {
	RUNNING,
	FAILURE,
	SUCCESS
}

func _init(engine, owner:NPC, target:Node) -> void:
	ENGINE = engine
	OWNER = owner
	TARGET = target
	ID = "use toilet"
	CHATTABLE = false
	LOCATION = target.LOCATION
	print("BLADDER LOCATION", LOCATION)


func tick() -> ActionResult:
	return run()



func run() -> ActionResult:
	var npc_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if OWNER.NEEDS["bladder"] >= 95:
		if !npc_room.is_secured():
			return ActionResult.new("end")
		else:
			var new_action:UnlockRoomAction = UnlockRoomAction.new(ENGINE, OWNER).room_to_unlock(npc_room).calling_action(self)
			return ActionResult.new("add", new_action)
	else:
		if OWNER.LOCATION == LOCATION:
			refresh_needs("bladder")
			return ActionResult.new("running")
		else:
			var new_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(TARGET).calling_action(self).secure_room()
			return ActionResult.new("add", new_action)
