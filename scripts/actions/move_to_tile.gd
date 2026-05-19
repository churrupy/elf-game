class_name MoveToTile extends ACTION

var ON_TILE:bool = false
var IN_TILE_ROOM:bool = false
var ROOM_SECURED:bool = false

var TILE_TAG:String
var secure_room:bool = false


func _init(engine, owner) -> void:
	ENGINE = engine
	OWNER = owner
	ID = "move to tile"


func set_tag(_tag:String) -> MoveToTile:
	TILE_TAG = _tag
	return self


func to_secure() -> MoveToTile:
	secure_room = true
	return self

func enter_state() -> void:
	print("entering: MoveToTileAction")
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if current_room.has_tag(TILE_TAG):
		IN_TILE_ROOM = true
		var filter:TILE_FILTER = TILE_FILTER.new(ENGINE).set_list().set_room(current_room).has_tag(TILE_TAG)
		var tiles:Array[TILE] = filter.run_filter()
		for t:TILE in tiles:
			if OWNER.LOCATION == t.LOCATION:
				ON_TILE = true
				return
		TARGET = tiles[0]
		if TARGET.has_tag("adjacent_only"):
			var location_filter:LOCATION_FILTER = LOCATION_FILTER.new(ENGINE).generate_list(TARGET.LOCATION).is_available().is_passable().is_not(TARGET.LOCATION)
			var adjacent_loc:Array[Vector2] = location_filter.run_filter()
			adjacent_loc.sort_custom(func(a,b):OWNER.LOCATION.distance_to(a) < OWNER.LOCATION.distance_to(b))
			LOCATION = adjacent_loc[0]
		else:
			LOCATION = tiles[0].LOCATION
		if secure_room:
			if current_room.is_secured():
				ROOM_SECURED = true
	else:
		IN_TILE_ROOM = false
		ON_TILE = false
		ROOM_SECURED = false
		
func run() -> ActionResult:
	if ON_TILE:
		return ActionResult.new("end")
	elif IN_TILE_ROOM:
		if secure_room:
			if ROOM_SECURED:
				var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_location(LOCATION).set_goal(self)
				return ActionResult.new("action", new_action)
			else:
				var new_action:ACTION = LockRoomAction.new(ENGINE, OWNER).set_goal(self)
				return ActionResult.new("add", new_action)
		else:
			var new_action:ACTION = MoveAction.new(ENGINE, OWNER).set_location(LOCATION).set_goal(self)
			return ActionResult.new("action", new_action)
	else:
		var new_action:ACTION = MoveToRoomAction.new(ENGINE, OWNER).set_tag(TILE_TAG)
		return ActionResult.new("add", new_action)
