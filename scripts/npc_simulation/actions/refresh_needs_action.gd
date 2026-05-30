class_name RefreshNeedsAction extends ACTION

var NEED:String

# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner
# 	ID = "refresh needs"

func set_need(_need:String) -> RefreshNeedsAction:
	NEED = _need
	return self

func run() -> ActionResult:
	if OWNER.NEEDS[NEED] >= 95:
		return ActionResult.new("end")
	refresh_needs("bladder")
	return ActionResult.new("running")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"refreshes",
		NEED
	]
	return " ".join(str_list)
