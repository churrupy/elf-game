class_name IntroduceGoal extends ACTION

var IS_INTRODUCED:bool = false

# func _init(engine, owner:NPC) -> void:
# 	ID = "introduce"
# 	ENGINE = engine
# 	OWNER = owner
# 	SEEABLE = true
# 	HEARABLE = true

#region builder
func set_target(target:NPC) -> IntroduceGoal:
	TARGET = target
	return self

func score() -> void:
	SCORE = 1

# func create_event() -> IntroduceAction:
# 	# this is for when the action is just saying something
# 	# not continuous, doesn't change game state, just a simple statement
# 	ENGINE.History.create_event(self)
# 	return self

#endregion builder

# func tick() -> ActionResult:
# 	var result:ActionResult = run()
# 	return result

func start_state() -> void:
	if OWNER.knows_npc(TARGET):
		IS_INTRODUCED = true
	else:
		IS_INTRODUCED = false

func run() -> ActionResult:
	var new_action:ACTION
	if !IS_INTRODUCED:
		new_action = IntroduceResponseGoal.new(ENGINE, TARGET).set_target(OWNER)
		TARGET.ACTION_RESPONSES.append(new_action)
	new_action = IntroduceAction.new(ENGINE, OWNER)
	
	return ActionResult.new("action", new_action)

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
	var id_list:Array[String] = ENGINE.GroupManager.get_group_participants(OWNER)
	var npc_list:Array[NPC] = ENGINE.NpcManager.get_npcs_from_ids(id_list)
	# if group changes then this no longer works :(
	# i'll have to fix that
	return npc_list
