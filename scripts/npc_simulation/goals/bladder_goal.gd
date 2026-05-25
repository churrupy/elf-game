class_name BladderGoal extends ACTION

var GOAL_STATUS:String = "running"
var ACTION_STATUS:String = "running"

var ON_TOILET:bool = false
var FULL_BLADDER:bool = false

func _init(engine, owner:NPC) -> void:
	ENGINE = engine
	OWNER = owner
	ID = "use toilet"
	CHATTABLE = false

func score() -> BladderGoal:
	if OWNER.NEEDS["bladder"] < 50:
		SCORE = 10 + (100 - OWNER.NEEDS["bladder"])
		if OWNER.NEEDS["bladder"] < 20:
			SCORE += 20
	# SCORE += 100 - OWNER.NEEDS["bladder"]
	# if OWNER.NEEDS["bladder"] < 50:
	# 	SCORE += 10
	
	# print("bladder score: ", SCORE)

	return self

	

#endregion builder


func enter_state() -> void:
	print("entering: BladderGoal")
	if OWNER.NEEDS["bladder"] >= 95:
		FULL_BLADDER = true
		return
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag("fill_bladder").is_available().set_location(OWNER.LOCATION)
	var toilets:Array[TILE] = filter.run_filter()
	if len(toilets) == 1:
		ON_TOILET = true

func run() -> ActionResult:
	if FULL_BLADDER:
		var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
		if current_room.is_secured():
			var new_action:ACTION = UnlockRoomAction.new(ENGINE, OWNER).set_goal(self)
			return ActionResult.new("add", new_action)
		else:
			return ActionResult.new("end")
	elif ON_TOILET:
		var new_action:ACTION = PeeAction.new(ENGINE, OWNER)
		return ActionResult.new("action", new_action)
	else:
		# var new_action:ACTION = MoveToToilet.new(ENGINE, OWNER) # goal
		var new_action:ACTION = MoveToTileGoal.new(ENGINE, OWNER).set_tag("fill_bladder").to_secure()
		return ActionResult.new("add", new_action)
