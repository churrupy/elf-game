class_name LeaveRoomAction extends ACTION

func _init(engine, owner:NPC, target:Node, moving_for:ACTION) -> void:
    ID = "move"
    ENGINE = engine
    OWNER = owner
    TARGET = target
    MOVING_FOR = moving_for
    CHATTABLE = moving_for.CHATTABLE
    ENGINE.GroupManager.leave_group(owner)


func tick() -> ActionResult:
    var result:ActionResult = run()
    OWNER.decay_needs()
    return result


func run() -> ActionResult:
    