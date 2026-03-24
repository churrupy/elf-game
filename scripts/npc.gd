extends Node2D

class_name NPC


var NAME
var ID
var COLOR
var LOCATION = [0,0]
var GENDER
var ACTION
var RECENT_TOPIC
var OPINIONS = {}
var RELATIONSHIPS = {}
var NEEDS = {
	"hunger": 50,
	"energy": 50,
	"release": 50,
	"social": 50,
	"fun": 50,
	"bladder": 50
}

var NAMES = {
	"male": ["Gerald", "Harry", "Irving", "Jackson", "Kyle", "Leon", "Michael", "Christopher", "Matthew", "Joshua", "David", "James", "Daniel", "Robert", "John", "Joseph", "Andrew", "Justin", "Ryan", "Brandon", "Jason", "William", "Jonathan", "Brian", "Kevin", "Eric", "Nicholas", "Timothy", "Adam", "Anthony", "Thomas", "Steven", "Benjamin", "Mark", "Scott", "Paul"],
	"female": ["Agatha", "Bridget", "Cassidy", "Daniella", "Eve", "Jennifer", "Jessica", "Amanda", "Sarah", "Ashley", "Stephanie", "Emily", "Nicole", "Elizabeth", "Heather", "Melissa", "Michelle", "Kimberly", "Amy", "Angela", "Tiffany", "Rebecca", "Rachel", "Laura", "Courtney", "Amber", "Christina", "Samantha", "Hannah", "Erin", "Katherine", "Megan", "Danielle", "Brittany", "Lauren"]
}

#region initialize
func initialize(ID_COUNTER):
	GENDER = ["male", "female"].pick_random()
	NAME = NAMES[GENDER].pick_random()
	ID = NAME + str(ID_COUNTER)
	COLOR = Color(randf_range(0,1), randf_range(0,1), randf_range(0,1))
	var topics = Dialogue.CONVERSATION_NODES.keys()
	for topic in topics:
		OPINIONS[topic] = randi_range(0,100)

	
func _init() -> void:
	SignalBus.say_topic.connect(hear_topic)

	
#endregion
	
#region tick
	
func decay_needs():
	for need in NEEDS:
		var decay = Constants.NEED_DECAY_RATES[need]
		NEEDS[need] -= decay

func clamp_needs():
	for need in NEEDS:
		NEEDS[need] = clamp(NEEDS[need], 0, 100)
		


#endregion

#region AI
func get_opinion(other_npc):
	# dummy function
	var id = other_npc.ID
	if other_npc in RELATIONSHIPS:
		return RELATIONSHIPS[id]
	else:
		return 0

func score_action(action):
	# score based on need
	action.SCORE += 100-NEEDS[action.NEED]
	if action.SCORE in ["hunger", "energy"]:
		action.SCORE += 10 # bonus for urgent needs

	# score based on preference
	if action.FOLLOWING != null:
		action.SCORE += get_opinion(action.FOLLOWING)

	# score based on distance
	var total_x = abs(LOCATION[0]- action.TARGET[0])
	var total_y = abs(LOCATION[1] - action.TARGET[1])
	action.SCORE -= total_x #distance is penalty
	action.SCORE -= total_y

	return action


	
#endregion



#region NEEDS
func has_urgent_needs():
	if NEEDS["hunger"] < 50:
		return true
	if NEEDS["energy"] < 50:
		return true
	return false


#endregion


#region utility
func _to_string():
	return NAME + " " + str(LOCATION)


#endregion


func hear_topic(speaker_id, topic, opinion, location):
	if speaker_id == ID:
		return
	print("signal delivered")
	print(location)
	print(LOCATION)
	if LOCATION[0] in range(location[0]-1, location[0]+2):
		if LOCATION[1] in range(location[1] -1, location[1]+2):
			if speaker_id not in RELATIONSHIPS:
				RELATIONSHIPS[speaker_id] = 0
			RECENT_TOPIC = topic
			var this_opinion = OPINIONS[topic]
			var diff = abs(this_opinion - opinion)
			if diff > 50:
				RELATIONSHIPS[speaker_id] -= 1
			elif diff > 25:
				pass
			else:
				RELATIONSHIPS[speaker_id] += 1
			print(NAME)
			print("topic heard")
			print(RECENT_TOPIC)
