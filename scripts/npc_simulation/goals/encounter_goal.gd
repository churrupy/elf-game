class_name EncounterGoal extends ACTION

var ACTION_GROUP:GROUP
var PARTICIPANTS:Array[NPC]
var LEADER:NPC


var END_ENCOUNTER:bool = false
var VALID_ROOM:bool = false
var EVERYONE_PRESENT:bool = false
var ROOM_SECURED:bool = false

# func _init(engine, owner:NPC) -> void:
# 	ENGINE = engine
# 	OWNER = owner
# 	ID = "encounter"
# 	CHATTABLE = false

func set_participants(npc_list:Array[NPC]) -> EncounterGoal:
	PARTICIPANTS = npc_list
	return self

func set_group(_group:GROUP) -> EncounterGoal:
	ACTION_GROUP = _group
	var id_list:Array[String] = ENGINE.GroupManager.get_group_participants_from_group(ACTION_GROUP)
	PARTICIPANTS = NPC_FILTER.new(ENGINE).set_list_from_ids(id_list).run_filter() # this is so stupid lol
	return self

func set_leader(_npc:NPC) -> EncounterGoal:
	# follow the leader
	LEADER = _npc
	return self

func set_location(loc:Vector2 = Vector2.INF) -> EncounterGoal:
	if loc == Vector2.INF:
		find_location()
	else:
		LOCATION = loc
	return self

# func validate() -> bool:
# 	if TARGET == null:
# 		return false
# 	return true



func find_location() -> void:
	print("looking for encounter location")
	var group_size: int = len(PARTICIPANTS)
	print("group size: ", group_size)
	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag("encounter_location").is_available().has_free_adjacent_tiles(group_size - 1)
	var tiles:Array[TILE] = filter.run_filter()
	# print(tiles)
	if len(tiles) > 0:
		tiles.sort_custom(func(a,b): return OWNER.LOCATION.distance_to(b.LOCATION) < OWNER.LOCATION.distance_to(a.LOCATION))
		TARGET = tiles[0]
		LOCATION = TARGET.LOCATION
		# probably could use a function that calculates the number of free tiles around a location
		# that sounds like it'll come in handy
	#return self

# func tick() -> ActionResult:
# 	return run()

# func initialize_group() -> void:
# 	OWNER.STATE_STACK = []
# 	for id:String in PARTICIPANTS:

# 		if id == OWNER.ID: continue

# 		#get free tile
# 		var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().is_available().in_range_of(LOCATION, 1.5).is_passable()
# 		var filtered_tiles:Array[TILE] = filter.run_filter()
# 		var chosen_location:Vector2 = filtered_tiles[0].LOCATION
# 		var npc:NPC = Global.NPCS[id]
# 		npc.GOAL_ACTION = EncounterAction.new(ENGINE, npc).set_group(ACTION_GROUP).set_location(chosen_location)
# 		npc.STATE_STACK = []


# func run() -> ActionResult:
# 	if LOCATION == Vector2.INF:
# 		print("no free encounter tiles")
# 		return ActionResult.new("end").continuing()
	
# 	if OWNER.LOCATION != LOCATION:

		
# 		for id:String in PARTICIPANTS:
# 			if id == OWNER.ID: continue
# 			var npc:NPC = Global.NPCS[id]
# 			var move_action:MoveAction = MoveAction.new(ENGINE, npc).calling_action(self).set_target(TARGET).set_location(LOCATION, 1.5).secure_room().set_group(ACTION_GROUP)
# 			ENGINE.NpcManager.add_state(move_action)

# 			# or maybe follow? idk lol

# 		var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).calling_action(self).set_target(TARGET).secure_room().set_group(ACTION_GROUP)
# 		return ActionResult.new("add", move_action).continuing()

# 		# give self move action
# 		# give all of group move action

# 	else:
# 		for id:String in PARTICIPANTS:
# 			if id == OWNER.ID: continue
# 			var npc:NPC = Global.NPCS[id]
# 			var new_action:MakeoutAction = MakeoutAction.new(ENGINE, OWNER).set_group(ACTION_GROUP)
# 			ENGINE.NpcManager.add_state(new_action)
		
# 		var new_action:MakeoutAction = MakeoutAction.new(ENGINE, OWNER).set_group(ACTION_GROUP)
# 		return ActionResult.new("replace", new_action).continuing()

# 	# return res

func start_state() -> void:
	# check there's still other people first
	if LEADER == null:
		LEADER = OWNER


	var id_list:Array[String] = ENGINE.GroupManager.get_group_participants_from_group(ACTION_GROUP)
	if len(id_list) <= 1:
		END_ENCOUNTER = true

	

	# move to room that can accomodate everyone
	# check if current room is valid spot
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
		VALID_ROOM = false
		EVERYONE_PRESENT = false

			
	# lock room
	# do the do

func run() -> ActionResult:
	if END_ENCOUNTER:
		return ActionResult.new("end")

	if !VALID_ROOM:
		var new_action:ACTION = MoveToRoomGoal.new(ENGINE, OWNER).set_tag("encounter_location")
		return ActionResult.new("add", new_action)

	if !EVERYONE_PRESENT:
		var new_action:ACTION = WaitAction.new(ENGINE, OWNER)
		return ActionResult.new("action", new_action)
	if !ROOM_SECURED:
		var new_action:ACTION = LockRoomGoal.new(ENGINE, OWNER).set_group(PARTICIPANTS).set_goal(self)
		return ActionResult.new("add", new_action)
	
	return ActionResult.new("running")

	

func populate_stack() -> void:
	print("Goal: Encounter Action")
	var new_action:MakeoutAction = MakeoutAction.new(ENGINE, OWNER).set_group(ACTION_GROUP)
	OWNER.STATE_STACK.append(new_action)

	if OWNER.LOCATION != LOCATION:
		var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).calling_action(self).set_location(LOCATION).secure_room().set_group(ACTION_GROUP)
		OWNER.STATE_STACK.append(move_action)
