class_name EncounterAction extends ACTION

var ACTION_GROUP:GROUP
var PARTICIPANTS:Array[String]

func _init(engine, owner:NPC) -> void:
	ENGINE = engine
	OWNER = owner
	ID = "encounter"
	CHATTABLE = false

func set_group(_group:GROUP) -> EncounterAction:
	ACTION_GROUP = _group
	PARTICIPANTS = ENGINE.GroupManager.get_group_participants_from_group(ACTION_GROUP)
	return self

func set_location(loc:Vector2 = Vector2.INF) -> EncounterAction:
	if loc == Vector2.INF:
		find_location()
	else:
		LOCATION = loc
	return self


# func _init(engine, owner:NPC, target:Node= null) -> void:
# 	ID = "encounter"
# 	super._init(engine, owner, target)


func find_location() -> void:
	print("looking for encounter location")
	var group_size: int = len(PARTICIPANTS)
	# print("group size: ", group_size)
	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag("encounter_location").is_available().has_free_adjacent_tiles(group_size - 1)
	var tiles:Array[TILE] = filter.run_filter()
	# print(tiles)
	if len(tiles) > 0:
		tiles.sort_custom(func(a,b): OWNER.LOCATION.distance_to(b.LOCATION) < OWNER.LOCATION.distance_to(a.LOCATION))
		TARGET = tiles[0]
		LOCATION = TARGET.LOCATION
		# probably could use a function that calculates the number of free tiles around a location
		# that sounds like it'll come in handy
	#return self

func tick() -> ActionResult:
	return run()


func run() -> ActionResult:
	if LOCATION == Vector2.INF:
		print("no free encounter tiles")
		return ActionResult.new("end").continuing()
	
	if OWNER.LOCATION != LOCATION:

		
		for id:String in PARTICIPANTS:
			if id == OWNER.ID: continue
			var npc:NPC = Global.NPCS[id]
			var move_action:MoveAction = MoveAction.new(ENGINE, npc).calling_action(self).set_target(TARGET).set_location(LOCATION, 1.5).secure_room().set_group(ACTION_GROUP)
			ENGINE.NpcManager.add_state(move_action)

			# or maybe follow? idk lol

		var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).calling_action(self).set_target(TARGET).secure_room().set_group(ACTION_GROUP)
		return ActionResult.new("add", move_action).continuing()

		# give self move action
		# give all of group move action

	else:
		for id:String in PARTICIPANTS:
			if id == OWNER.ID: continue
			var npc:NPC = Global.NPCS[id]
			var new_action:MakeoutAction = MakeoutAction.new(ENGINE, OWNER).set_group(ACTION_GROUP)
			ENGINE.NpcManager.add_state(new_action)
		
		var new_action:MakeoutAction = MakeoutAction.new(ENGINE, OWNER).set_group(ACTION_GROUP)
		return ActionResult.new("replace", new_action).continuing()

	# return res
