class_name RespondAction extends ACTION

var HAS_REQUESTS:bool = false

func _init(engine, owner) -> void:
    ENGINE = engine
    OWNER = owner
    ID = "respond"

func enter_state() -> void:
    if len(OWNER.RESPONSE_REQUESTS) > 0:
        HAS_REQUESTS = true
    else:
        HAS_REQUESTS = false


func run() -> ActionResult:
    var res:ActionResult
    if !HAS_REQUESTS:
        return ActionResult.new("end")
    for _action:ACTION in OWNER.RESPONSE_REQUESTS:
        res = _action.process_response()
        if res != null:
            break
    
    OWNER.RESPONSE_REQUESTS = []
    return res
    