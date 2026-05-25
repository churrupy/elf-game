class_name MoveGoal extends ACTION

var VALID_LOCATIONS:Array[Vector2]
var INVALID_LOCATIONS:Array[Vector2]
var LOCATION_TAG:String

var IN_ROOM:bool = false
var TAG:String 

func _init(engine, owner) -> void:
	ENGINE = engine
	OWNER = owner
	ID = "move"

func set_tag(tag:String) -> MoveGoal:
	LOCATION_TAG = tag
	return self


func generate_locations() -> MoveGoal:
	var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().has_tag(LOCATION_TAG)
	filter.run_filter()
	var loc_list:Array[Vector2] = filter.convert_to_loc()
	loc_list.sort_custom(func(a,b):OWNER.LOCATION.distance_to(a.LOCATION) < OWNER.LCOATION.distance_to(b.LOCATION))
	VALID_LOCATIONS = loc_list
	LOCATION = VALID_LOCATIONS[0]
	return self

func validate() -> ActionResult:
	if OWNER.LOCATION == LOCATION:
		return ActionResult.new("end")
	else:
		var move_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_location(LOCATION)
		return ActionResult.new("action", move_action)

