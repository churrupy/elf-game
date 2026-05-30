class_name TalkAction extends ACTION

var STATEMENTS:Array[ACTION]


# func _init(engine, owner) -> void:
# 	ID = "talk"
# 	ENGINE = engine
# 	OWNER = owner

func add_statement(_statement:ACTION) -> TalkAction:
	STATEMENTS.append(_statement)
	return self

func run() -> ActionResult:
	print("running: TalkAction")
	for s:ACTION in STATEMENTS:
		s.create_event()
	return ActionResult.new("end turn")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"is conversing"
	]
	return " ".join(str_list)