class_name IntroduceAction extends ACTION

func _init(engine, owner:NPC) -> void:
	ID = "introduce"
	ENGINE = engine
	OWNER = owner
	LOCATION = owner.LOCATION
	SEEABLE = true
	HEARABLE = true

#region builder
func set_target(target:NPC) -> IntroduceAction:
	TARGET = target
	return self

func create_event() -> IntroduceAction:
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

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"introduces themselves"
	]

	if TARGET != null:
		str_list += [
			"to",
			TARGET.NAME
		]
		
	return " ".join(str_list)

func get_involved_npcs() -> Array[NPC]:
	var npc_list:Array[NPC] = ENGINE.GroupManager.get_group_participants(OWNER)
	# if group changes then this no longer works :(
	# i'll have to fix that
	return npc_list
