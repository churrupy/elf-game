class_name MoveToRoomAction extends ACTION

var ROOM_TAG:String

var TARGET_ROOM:ROOM
var TARGET_DOOR:DOOR

var IN_ROOM:bool = false

func _init(engine, owner) -> void:
	ENGINE = engine
	OWNER = owner
	ID = "move to room"

func set_tag(_tag:String) -> MoveToRoomAction:
	ROOM_TAG = _tag
	return self


func enter_state() -> void:
	var current_room:ROOM = ENGINE.Map.get_room(OWNER.LOCATION)
	if current_room.has_tag(ROOM_TAG):
		print("current room has tag")
		IN_ROOM = true
	else:
		print("current room does not have tag")
		var room_filter:ROOM_FILTER = ROOM_FILTER.new(ENGINE).set_list().has_tag(ROOM_TAG)
		var filtered_rooms:Array[ROOM] = room_filter.run_filter()
		print("filtered rooms: ", filtered_rooms)
		for room:ROOM in filtered_rooms:
			print("checking against ", room)
			if current_room == room:
				print("current room", current_room)
				print('checked room', room)
				IN_ROOM = true
				return
		
		if len(filtered_rooms) > 0:
			TARGET_ROOM = filtered_rooms[0]
			TARGET_DOOR = TARGET_ROOM.DOOR_LIST[0]


func run() -> ActionResult:
	print("IN_ROOM: ", IN_ROOM, ", TARGET_ROOM:", TARGET_ROOM)
	if IN_ROOM:
		return ActionResult.new("end")
	elif TARGET_ROOM == null:
		# no valid rooms found
		return ActionResult.new("end")
	else:
		var new_action:MoveAction = MoveAction.new(ENGINE, OWNER).set_target(TARGET_DOOR).set_goal(self)
		return ActionResult.new("action", new_action)
