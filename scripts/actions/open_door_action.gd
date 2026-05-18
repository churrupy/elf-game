class_name OpenDoorAction extends ACTION

var AT_DOOR:bool = false
var DOOR_OPEN:bool = false

func _init(engine, owner) -> void:
    ID = "open door"
    ENGINE = engine
    OWNER = owner

func set_target(_door:DOOR) -> OpenDoorAction:
    TARGET = _door
    return self

func enter_state() -> void:
    if OWNER.LOCATION == TARGET.LOCATION:
        AT_DOOR = true
        if TARGET.opened:
            DOOR_OPEN = true

func run() -> ActionResult:
    if AT_DOOR:
        if DOOR_OPEN:
            return ActionResult.new("end")
        else:
            TARGET.open() # i'll fix this flagrant disregard for consistency later
            return ActionResult.new("running")
    else:
        var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_location(TARGET.LOCATION).set_goal(self)
        return ActionResult.new("action", new_action)