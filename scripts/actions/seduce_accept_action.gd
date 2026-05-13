class_name SeduceAcceptAction extends ACTION

func _init(engine, owner:NPC) -> void:
	ID = "seduce"
	ENGINE = engine
	OWNER = owner
	HEARABLE = true

func set_target(_target:NPC) -> SeduceAcceptAction:
	TARGET = _target
	TARGET.add_response(self)
	return self

func create_event() -> SeduceAcceptAction:
	ENGINE.History.create_event(self)
	return self

func tick() -> ActionResult:
	return run()

func run() -> ActionResult:
	return ActionResult.new("end")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"accepts",
		TARGET.NAME,
		"'s seduction."
	]
	return " ".join(str_list)

func get_involved_npcs() -> Array[NPC]:
	return [OWNER, TARGET]

func process_response() -> ActionResult:
	# processes response from target
	# target is the seduce initiator
	var same_group:bool = ENGINE.GroupManager.is_in_same_group(TARGET, OWNER)
	if !same_group:
		return null

	var group:GROUP = ENGINE.GroupManager.create_group_from_list([TARGET, OWNER])
	# var group:GROUP = ENGINE.GroupManager.create_group(TARGET)
	# ENGINE.GroupManager.join_npc(OWNER, TARGET)
	var new_action: EncounterAction = EncounterAction.new(ENGINE, TARGET).set_group(group).set_location()
	return ActionResult.new("add", new_action).continuing()
