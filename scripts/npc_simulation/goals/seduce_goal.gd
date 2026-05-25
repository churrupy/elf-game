class_name SeduceGoal extends ACTION

var TARGET_SEDUCABLE:bool = false
var SEDUCTION_ATTEMPT:bool = false

func _init(engine, owner: NPC) -> void:
	# i hope this works lol
	ID = "seduce"
	ENGINE = engine
	OWNER = owner
	HEARABLE = true

func set_target(_target:NPC) -> SeduceGoal:
	TARGET = _target
	TARGET.add_response(self)
	return self

func start_state() -> void:
	if TARGET.has_goal_id_in_stack("encounter"):
		# already made plans
		TARGET_SEDUCABLE = false
	else:
		TARGET_SEDUCABLE = true


func run() -> ActionResult:
	var new_action:ACTION
	if SEDUCTION_ATTEMPT:
		return ActionResult.new("end")
	if TARGET_SEDUCABLE:
		new_action = SeduceResponseGoal.new(ENGINE, TARGET).set_target(OWNER)
		TARGET.ACTION_RESPONSES.append(new_action)
		SEDUCTION_ATTEMPT = true
	new_action = SeduceAction.new(ENGINE, OWNER).set_target(TARGET)
	return ActionResult.new("action", new_action)

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"attempts to seduce",
		TARGET.NAME
	]

	return " ".join(str_list)

func get_involved_npcs() -> Array[NPC]:
	return [OWNER, TARGET]


func process_response() -> ActionResult:
	if TARGET.has_goal_id_in_stack("encounter"):
		return null
	var new_action:ACTION = TalkAction.new(ENGINE, OWNER)
	var statement:ACTION = SeduceAcceptAction.new(ENGINE, TARGET).set_target(OWNER)
	new_action.add_statement(statement)
	return ActionResult.new("action", new_action)
