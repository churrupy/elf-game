class_name SeduceAction extends ACTION

# func _init(engine, owner):
# 	ID = "seduce"
# 	ENGINE = engine
# 	OWNER = owner

func set_target(_target:NPC) -> SeduceAction:
	TARGET = _target
	return self

func run() -> ActionResult:
	ENGINE.History.add_event(self)
	return ActionResult.new("end turn")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"attempts to seduce",
		TARGET.NAME
	]
	
	return " ".join(str_list)

func get_involved_npcs() -> Array[NPC]:
	return [OWNER, TARGET]
