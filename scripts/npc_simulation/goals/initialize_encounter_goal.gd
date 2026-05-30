class_name InitializeEncounterGoal extends ACTION

var PARTICIPANTS:Array[NPC]

var VALID_ENCOUNTER:bool = false
var VALID_ROOM:bool = false
var EVERYONE_PRESENT:bool = false
var ROOM_SECURED:bool = false

var IS_READY:bool = false

# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner
# 	ID = "encounter"

func set_participants(npc_list:Array[NPC]) -> InitializeEncounterGoal:
	PARTICIPANTS = npc_list.duplicate()
	return self


# goals:
# 	find room
# 	go to room with group
# 	lock room
# 	give everyone encounter goals

func start_state() -> void:
	# check that there's at least one person in participants
	if len(PARTICIPANTS) >= 1:
		VALID_ENCOUNTER = true

	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if current_room.has_tag("encounter_location"):
		VALID_ROOM = true

		EVERYONE_PRESENT = true
		for npc:NPC in PARTICIPANTS:
			var npc_room:ROOM = ENGINE.Map.get_room(npc.LOCATION)
			if npc_room != current_room:
				EVERYONE_PRESENT = false
				break
		
		if current_room.is_secured():
			ROOM_SECURED = true

	else:
		VALID_ENCOUNTER = false
		VALID_ROOM = false
		EVERYONE_PRESENT = false
		ROOM_SECURED = false

# func run() -> ActionResult:
# 	if !VALID_ENCOUNTER:
# 		return ActionResult.new("end")

# 	var new_goal:ACTION

# 	if !VALID_ROOM:
# 		new_goal = MoveToRoomGoal.new(ENGINE, OWNER).set_tag("encounter_location")#.set_participants(PARTICIPANTS)
# 		return ActionResult.new("add", new_goal)

# 	if !EVERYONE_PRESENT or !ROOM_SECURED:
# 		new_goal = LockRoomGoal.new(ENGINE, OWNER).set_participants(PARTICIPANTS)
# 		return ActionResult.new("add", new_goal)

# 	# also add EncounterGoal to everyone else as well here
# 	for p:NPC in PARTICIPANTS:
# 		if p == OWNER: continue
# 		new_goal = EncounterWaitGoal.new(ENGINE, p).set_target(OWNER)
# 		p.GOAL_STACK.append(new_goal)

# 	new_goal = EncounterGoal.new(ENGINE, OWNER).set_participants(PARTICIPANTS)
# 	return ActionResult.new("replace", new_goal)
