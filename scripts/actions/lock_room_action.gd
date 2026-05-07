class_name LockRoomAction extends ACTION

var MOVING_FOR:ACTION
var PATH: Array[Vector2]
var TARGET_ROOM:ROOM

var GROUP:Array[NPC]

func _init(engine, owner:NPC) -> void:
	ID = "move"
	ENGINE = engine
	OWNER = owner

func room_to_secure(_room:ROOM) -> LockRoomAction:
	TARGET_ROOM = _room
	return self

func calling_action(moving_for:ACTION) -> LockRoomAction:
	MOVING_FOR = moving_for
	CHATTABLE = moving_for.CHATTABLE
	return self

func set_group(_group:Array[NPC]) -> LockRoomAction:
	GROUP = _group.duplicate()
	return self

func tick() -> ActionResult:
	var result:ActionResult = run()
	OWNER.decay_needs()
	return result

func run() -> ActionResult:
	# shoo out other npcs
	var filter: NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().is_in_room(TARGET_ROOM).is_not([OWNER])
	var npcs_in_room:Array[NPC] = filter.run_filter()
	# shoo out non-group npcs
	if len(npcs_in_room) > 0:
		for npc:NPC in npcs_in_room:
			if npc in GROUP: continue
			var current_action = npc.STATE_STACK.back()
			if current_action is not LeaveRoomAction or current_action is not ShooAction:
				var leave_action:ShooAction = ShooAction.new(ENGINE, npc).set_location()
				ENGINE.NpcManager.add_state(leave_action)
				# var leave_action:LeaveRoomAction = LeaveRoomAction.new(ENGINE, npc).set_location().calling_action(self)
				# ENGINE.NpcManager.add_state(leave_action)
		return ActionResult.new("running")

	# wait for all group npcs to arrive
	# does not check to make sure that NPCs are still available
	for npc:NPC in GROUP:
		if npc not in npcs_in_room:
			return ActionResult.new("running")
	
	# lock doors
	for door:DOOR in TARGET_ROOM.DOOR_LIST:
		if door.opened:
			if OWNER.LOCATION == door.LOCATION:
				door.close()
			else:
				var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(door).calling_action(self)
				return ActionResult.new("add", move_action)
	return ActionResult.new("continue")


func _to_string() -> String:
	var str_list:Array[String] = [
		"[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is locking room for",
		MOVING_FOR.ID
	]
	return " ".join(str_list)
