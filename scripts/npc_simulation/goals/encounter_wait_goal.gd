class_name EncounterWaitGoal extends ACTION

var NEAR_TARGET:bool = false
var ENCOUNTER_READY:bool = false

# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner

func set_target(_target:NPC) -> EncounterWaitGoal:
	TARGET = _target
	return self

func enter_state() -> void:
	var target_goal:ACTION = OWNER.GOAL_STACK.back()
	if target_goal.ENCOUNTER_READY:
		ENCOUNTER_READY = true

	else:
		ENCOUNTER_READY = false
		if OWNER.LOCATION.distance_to(TARGET.LOCATION) <= 1.5:
			NEAR_TARGET = true
		else:
			NEAR_TARGET = false

func run() -> ActionResult:
	var new_action:ACTION
	if ENCOUNTER_READY:
		var target_goal:ACTION = OWNER.GOAL_STACK.back()
		new_action = EncounterGoal.new(ENGINE, OWNER).set_participants(target_goal.PARTICIPANTS)
		return ActionResult.new("replace", new_action)
	
	if !NEAR_TARGET:
		var tile_list:Array[TILE] = TILE_FILTER.new(ENGINE).set_list().in_range_of(TARGET.LOCATION, 1.5).is_passable().run_filter()
		if len(tile_list) > 0:
			tile_list.sort_custom(func(a,b): return a.distance_to(OWNER.LOCATION) < b.distance_to(OWNER.LOCATION))
			new_action = MoveAction.new(ENGINE, OWNER).set_location(tile_list[0].LOCATION)
			return ActionResult.new("action", new_action)

	new_action = WaitAction.new(ENGINE, OWNER)
	return ActionResult.new("action", new_action)
		