class_name ACTIONS


var TARGET # location of target
var LOCATION # adjacent to target, if necessary (if not necessary, then will be the same as location)
var ID: String
var NEED: String
var STATUS = "moving" # idk that enum thing again
var SCORE: int
var COUNTDOWN: int
var FOLLOWING # node
var MOVING = false # triggers whether location is rechecked every turn
var ON_TILE = true # whether npc needs to be on tile to do action


func set_countdown():
	var action_dict = Constants.ACTION_TEMPLATES[ID]
	COUNTDOWN = action_dict["duration"]

func do(npc):
	COUNTDOWN -= 1
	var refresh_rate = Constants.NEED_REFRESH_RATES[NEED]
	npc.NEEDS[NEED] += refresh_rate
	if COUNTDOWN < 0:
		STATUS = "finish"


func update_location():
	if MOVING:
		LOCATION = TARGET.LOCATION.duplicate()


func is_at_location(npc_location):
	if ON_TILE:
		if npc_location == LOCATION:
			return true
	else:
		var x_diff = abs(npc_location[0] - LOCATION[0])
		var y_diff = abs(npc_location[1] - LOCATION[1])
		if (x_diff + y_diff <=2):
			return true
		return false



#region utility

func is_joinable():
	var action_dict = Constants.ACTION_TEMPLATES[ID]
	return action_dict["joinable"]

func can_do_off_tile():
	# eg can only go to the bathroom on the bathroom tile, but can drink without sitting on top of the bar
	var action_dict = Constants.ACTION_TEMPLATES[ID]
	return action_dict["do_off_tile"]

func is_conversable():
	var action_data = Constants.ACTION_TEMPLATES[ID]
	if "conversable" in action_data: # default is true
		return false
	return true

func _to_string():
	var _str = STATUS
	if STATUS == "moving":
		_str = ID + ": moving to " + str(LOCATION) + " for " + str(COUNTDOWN) + " more minutes"
	elif STATUS == "filling":
		_str = ID + " at " + str(LOCATION) + " for " + str(COUNTDOWN) + " more minutes"
	if FOLLOWING != null:
		_str += " with " + FOLLOWING.NAME
	_str += " Score: " + str(SCORE)
	return _str

#endregion
