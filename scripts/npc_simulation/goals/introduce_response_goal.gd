class_name IntroduceResponseGoal extends ACTION

var HAS_RESPONDED:bool = false

func _init(engine, owner) -> void:
    ID = "introduce"
    ENGINE = engine
    OWNER = owner

func set_target(_npc:NPC) -> IntroduceResponseGoal:
    TARGET = _npc
    return self

func score() -> void:
    SCORE = 1

func start_state() -> void:
    pass

func run() -> ActionResult:
    if HAS_RESPONDED:
        return ActionResult.new("end")
    var new_action:ACTION = IntroduceAction.new(ENGINE, OWNER)
    HAS_RESPONDED = true
    return ActionResult.new("action", new_action)