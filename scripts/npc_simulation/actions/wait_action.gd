class_name WaitAction extends ACTION

var WAITED:bool = false

# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner

#func set_goal(goal:ACTION) -> WaitAction:
	#GOAL = goal
	#return self

func run() -> ActionResult:
	if WAITED:
		return ActionResult.new("success")
	else:
		WAITED = true
		return ActionResult.new("running")


func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is waiting because of",
		str(GOAL)
	]
	return " ".join(str_list)
