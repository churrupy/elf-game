class_name PromptIntroduceAction extends ACTION

func _init(engine, owner:NPC) -> void:
	ID = "prompt introduce"
	ENGINE = engine
	OWNER = owner
	LOCATION = owner.LOCATION
	SEEABLE = true
	HEARABLE = true

#region builder
func set_target(target:NPC) -> PromptIntroduceAction:
	TARGET = target
	TARGET.add_response(self)
	return self

func create_event() -> PromptIntroduceAction:
	# this is for when the action is just saying something
	# not continuous, doesn't change game state, just a simple statement
	ENGINE.History.create_event(self)
	return self

#endregion builder

func tick() -> ActionResult:
	var result:ActionResult = run()
	return result

func run() -> ActionResult:
	return ActionResult.new("end")
	# # ENGINE.History.create_event(self)
	# TARGET.add_response(self)
	# return ActionResult.new("end")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"asks",
		TARGET.NAME,
		"for their name."
	]
	return " ".join(str_list)

func get_involved_npcs() -> Array[NPC]:
	var npc_list:Array[NPC] = [OWNER, TARGET]
	return npc_list

func process_response(npc:NPC) -> ACTION:
	# check they're still in the same group
	var same_group:bool = ENGINE.GroupManager.is_in_same_group(OWNER, npc)
	if !same_group:
		return null
	# they're always going to respond for now
	var new_action:IntroduceAction = IntroduceAction.new(ENGINE, npc).set_target(OWNER).create_event()
	return new_action