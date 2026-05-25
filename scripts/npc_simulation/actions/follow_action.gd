class_name FollowAction extends ACTION

var CLEAR:bool = false

func _init(engine, owner:NPC) -> void:
    ENGINE = engine
    OWNER = owner

func set_target(_target:NPC) -> FollowAction:
    TARGET = _target
    return self

func tick() -> ActionResult:
    return run()


func run() -> ActionResult:
    if OWNER.LOCATION.distance_to(TARGET.LOCATION) > 1.5:
        # attempt to move closer


    