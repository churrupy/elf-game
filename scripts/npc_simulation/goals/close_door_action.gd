class_name CloseDoorAction extends ACTION

var AT_DOOR:bool = false
var DOOR_CLOSED:bool = false


# func _init(engine, owner) -> void:
#     ID = "close door"
#     ENGINE = engine
#     OWNER = owner


func set_target(_door:DOOR) -> CloseDoorAction:
	TARGET = _door
	return self

# func enter_state() -> void:
#     if OWNER.LOCATION == TARGET.LOCATION:
#         AT_DOOR = true
#         if !TARGET.opened:
#             DOOR_CLOSED = true

func run() -> ActionResult:
	if "target_door" not in OWNER.BLACKBOARD or OWNER.BLACKBOARD["target_door"] == null:
		return ActionResult.new("fail")

	var target_door:DOOR = OWNER.BLACKBOARD["target_door"]
	if OWNER.LOCATION != target_door.LOCATION:
		ENGINE.NpcManager.remember_location(OWNER, target_door.LOCATION)
		# var new_action:ACTION = MoveAction.new(ENGINE, OWNER)
		add_action(MoveAction)
		return ActionResult.new("running")
	target_door.close()
	return ActionResult.new("success")

func _to_string() -> String:
	var target_door:DOOR = OWNER.BLACKBOARD["target_door"]
	var str_list:Array[String] = [
		OWNER.NAME,
		"is closing the door at",
		ENGINE.prettify_vector(target_door.LOCATION)
	]
	return " ".join(str_list)

# func run() -> ActionResult:
#     if AT_DOOR:
#         if DOOR_CLOSED:
#             return ActionResult.new("end")
#         else:
#             TARGET.close() # idc that this is changing the game state, i'll fix this when i clean up EVERYTHING ELSE
#             return ActionResult.new("running")
#     else:
#         var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_location(TARGET.LOCATION).set_goal(self)
#         return ActionResult.new("action", new_action)
