class_name DanceAction extends ACTION

# func _init(engine, owner:NPC) -> void:
# 	ID = "dance"
# 	ENGINE = engine
# 	OWNER = owner

func run() -> ActionResult:
	refresh_needs("fun")
	ENGINE.History.add_event(self)
	return ActionResult.new("end turn")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"dances their heart out."
	]
	return " ".join(str_list)



# func run() -> ActionResult:
# 	refresh_needs("fun")
# 	#ENGINE.History.add_event(OWNER.ID, "dances")

# 	#chitchat()

# 	COUNTDOWN -= 1
# 	if COUNTDOWN < 0:
# 		return ActionResult.new("end", null)
# 		#return ["end", null]
# 	return ActionResult.new("running", null)
# 	#return ["running", null]
