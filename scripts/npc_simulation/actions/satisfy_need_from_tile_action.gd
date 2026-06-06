class_name SatisfyNeedFromTileAction extends ACTION

# func _init(engine, owner) -> void:
# 	ENGINE = engine
# 	OWNER = owner

func set_id() -> void:
	ID = "SatisfyNeedFromTileAction"


func run() -> ActionResult:
	if "target_tile" not in OWNER.BLACKBOARD:
		STATUS = "fail"
		return ActionResult.new("end")

	var target_tile:TILE = OWNER.BLACKBOARD["target_tile"]
	if OWNER.LOCATION != target_tile.LOCATION:
		STATUS = "fail"
		return ActionResult.new("end")

	var need:String = OWNER.BLACKBOARD["target_need"]
	if OWNER.NEEDS[need] >= 95:
		STATUS = "success"
		return ActionResult.new("end")
	refresh_needs(need)
	return ActionResult.new("running")


func _to_string() -> String:
	var tile:TILE = OWNER.BLACKBOARD["target_tile"]
	var room:ROOM = OWNER.BLACKBOARD["target_room"]
	var need:String = OWNER.BLACKBOARD["target_need"]

	var str_list:Array[String] = [
		OWNER.NAME,
		"is using",
		tile.TYPE,
		"in the",
		room.TYPE,
		"to fulfill",
		need
	]

	return " ".join(str_list)