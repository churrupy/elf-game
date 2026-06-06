class_name ACTION extends RefCounted

var ENGINE
var ID: String
var OWNER: NPC

var DATA:Dictionary

var STATUS:String = "running"


var TARGET: Node 
var LOCATION: Vector2 = Vector2.INF 
var COUNTDOWN: int
var SCORE: float = 0.0

var GOAL:ACTION
var CHATTABLE: bool = false
var SEEABLE:bool = false
var HEARABLE:bool = false


var POSE:String = "standing"
var PHYSICAL_ACTION:String = ""

var CURRENT_ACTION:ACTION



var ACTION_DATA:Dictionary = {
	"SocializeAction": {
		"chattable": "true"
	},
	"FunAction": {
		"chattable": "true"
	},
}


func _init(engine, owner:NPC, _goal:ACTION=null) -> void:
	ENGINE = engine
	OWNER = owner
	GOAL = _goal
	set_id()
	if ID in ACTION_DATA.keys():
		DATA = ACTION_DATA[ID]
		var chat_data:String = DATA["chattable"]
		match chat_data:
			"true":
				CHATTABLE = true
			"false":
				CHATTABLE = false
			_:
				CHATTABLE = GOAL.CHATTABLE
	elif GOAL != null:
		CHATTABLE = GOAL.CHATTABLE
	else:
		CHATTABLE = false


func set_id() -> void:
	ID = "GenericAction"

func start_action() -> void:
	pass

func end_action() -> void:
	pass

# func set_goal(_goal:ACTION) -> ACTION:
# 	GOAL = _goal
# 	CHATTABLE = GOAL.CHATTABLE
# 	return self

func set_current_action(_action:GDScript, owner=OWNER) -> void:
	# print("set current action")
	CURRENT_ACTION = _action.new(ENGINE, owner, self)
	# print("adding action: ", CURRENT_ACTION.ID)
	CURRENT_ACTION.add_self_to_owner()

func add_action(_action:GDScript, owner=OWNER) -> void:
	# print("add action")
	var new_action:ACTION = _action.new(ENGINE, owner, self)
	# print("adding action: ", new_action.ID)
	new_action.add_self_to_owner()


func add_self_to_owner() -> void:
	# print("add self to owner")
	print("adding action: ", ID)
	OWNER.ACTION_STACK.append(self)
	start_action()


# func enter_state():
# 	pass

# func exit_state() -> ACTION:
# 	return null


# func suspend_state():
# 	pass

# func resume_state():
# 	pass




func can_do_action() -> bool:
	return true


func run() -> ActionResult:
	# extends
	return ActionResult.new("running")


func _to_string():
	var str_list:Array[String] = [
		# "[ACTION]",
		#"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"is",
		ID
	]
	return " ".join(str_list)

func refresh_needs(need:String) -> void:
	var refresh_rate: float = Constants.NEED_REFRESH_RATES[need]
	OWNER.NEEDS[need] += refresh_rate




#region new action functions
func get_room() -> ROOM:
	var room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	return room

func is_equal(_event:EVENT_new) -> bool:
	# use this for non-ongoing events
	return false 

func get_role(npc:NPC) -> String:
	if npc == OWNER:
		return "participant"
	else:
		return "witness"

#endregion new action functions
