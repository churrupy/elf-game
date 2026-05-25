class_name SeduceResponseGoal extends ACTION

var HAS_RESPONDED:bool = false

func _init(engine, owner) -> void:
	print("seduce response check", owner.NAME)
	ID = "seduce"
	ENGINE = engine
	OWNER = owner

func set_target(_npc:NPC) -> SeduceResponseGoal:
	TARGET = _npc
	return self

func score() -> void:
	if OWNER.has_goal_id_in_stack("encounter"):
		SCORE = -1
	else:
		SCORE = 1

func start_state() -> void:
	pass

func run() -> ActionResult:
	if HAS_RESPONDED:
		return ActionResult.new("end")
	var new_action:ACTION = InitializeEncounterGoal.new(ENGINE, TARGET).set_group([TARGET, OWNER])
	TARGET.GOAL_STACK.append(new_action)
	new_action = SeduceAcceptAction.new(ENGINE, OWNER)
	HAS_RESPONDED = true
	return ActionResult.new("action", new_action)
