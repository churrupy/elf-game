class_name ACTIONS


var TARGET # location of target
var LOCATION # adjacent to target, if necessary (if not necessary, then will be the same as location)
var ID: String
var NEED: String
var STATUS = "moving" # idk that enum thing again
var SCORE: int
var COUNTDOWN: int
var FOLLOWING # node


func set_countdown():
	var action_dict = Constants.ACTION_TEMPLATES[ID]
	COUNTDOWN = action_dict["duration"]

func do(npc):
	COUNTDOWN -= 1
	print("in actions", STATUS)
	if ID == "converse":
		process_conversation(npc)
	var refresh_rate = Constants.NEED_REFRESH_RATES[NEED]
	npc.NEEDS[NEED] += refresh_rate
	if COUNTDOWN < 0:
		STATUS = "finish"
	print("after actions", npc.NAME,_to_string())


#region special
func process_conversation(npc):
	npc.RECENT_TOPIC = Dialogue.get_next_topic(npc.RECENT_TOPIC)

#endregion




#region utility

func is_joinable():
	var action_dict = Constants.ACTION_TEMPLATES[ID]
	return action_dict["joinable"]

func can_do_off_tile():
	# eg can only go to the bathroom on the bathroom tile, but can drink without sitting on top of the bar
	var action_dict = Constants.ACTION_TEMPLATES[ID]
	return action_dict["do_off_tile"]

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
