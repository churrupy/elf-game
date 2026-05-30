class_name SeduceAcceptAction extends ACTION

# func _init(engine, owner:NPC) -> void:
# 	ID = "seduce"
# 	ENGINE = engine
# 	OWNER = owner
# 	HEARABLE = true

func set_target(_target:NPC) -> SeduceAcceptAction:
	TARGET = _target
	TARGET.add_response(self)
	return self


func run() -> ActionResult:
	ENGINE.History.add_event(self)
	return ActionResult.new("end turn")

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
