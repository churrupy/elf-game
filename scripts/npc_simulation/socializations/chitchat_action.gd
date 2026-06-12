class_name ChitChatAction extends ACTION

func score() -> ChitChatAction:
	SCORE = 0.4
	return self

func set_id() -> void:
	ID = "ChitChatAction"

func run() -> ActionResult:
	ENGINE.History.add_event(self)
	STATUS = "success"
	return ActionResult.new("end turn")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"chit-chats with the group."
	]
	return " ".join(str_list)