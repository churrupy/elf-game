class_name IntroduceAction extends ACTION

# func _init(engine, owner):
# 	ENGINE = engine
# 	OWNER = owner

func run() -> ActionResult:
	ENGINE.History.add_event(self)
	return ActionResult.new("end turn")

func get_involved_npcs() -> Array[NPC]:
	return [OWNER]


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