class_name MoveToToilet extends ACTION

var GOAL_STATUS:String = "running"
var ACTION_STATUS:String = "running"

var ON_TOILET:bool = false
var IN_BATHROOM:bool = false
var ROOM_SECURED:bool = false


func _init(engine, owner) -> void:
	ENGINE = engine
	OWNER = owner
	ID = "move to toilet"

func enter_state() -> void:
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().set_room(current_room).has_tag("fill_bladder")
	var toilets:Array[TILE] = filter.run_filter()
	if len(toilets) >= 1:
		IN_BATHROOM = true
		for t:TILE in toilets:
			if OWNER.LOCATION == t.LOCATION:
				ON_TOILET = true
				return
		LOCATION = toilets[0].LOCATION
		if current_room.is_secured():
			ROOM_SECURED = true

func run() -> ActionResult:
	if ON_TOILET:
		return ActionResult.new("end")
	elif IN_BATHROOM:
		if ROOM_SECURED:
			var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_location(LOCATION).set_goal(self)
			return ActionResult.new("action", new_action)
		else:
			var new_action:ACTION = LockRoomAction.new(ENGINE, OWNER).set_goal(self)
			return ActionResult.new("add", new_action)
	else:
		var new_action:ACTION = MoveToRoomAction.new(ENGINE, OWNER).set_tag("fill_bladder")
		return ActionResult.new("add", new_action)
