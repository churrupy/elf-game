extends Node2D

class_name NPC


var NAME
var ID
var COLOR
var LOCATION = [0,0]
var GENDER
var ACTION
var RECENT_TOPIC
var STYLE
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

var STYLES = ["goth", "punk", "prep", "country", "athletic", "queer"]

var NAMES = {
	"male": ["Gerald", "Harry", "Irving", "Jackson", "Kyle", "Leon", "Michael", "Christopher", "Matthew", "Joshua", "David", "James", "Daniel", "Robert", "John", "Joseph", "Andrew", "Justin", "Ryan", "Brandon", "Jason", "William", "Jonathan", "Brian", "Kevin", "Eric", "Nicholas", "Timothy", "Adam", "Anthony", "Thomas", "Steven", "Benjamin", "Mark", "Scott", "Paul"],
	"female": ["Agatha", "Bridget", "Cassidy", "Daniella", "Eve", "Jennifer", "Jessica", "Amanda", "Sarah", "Ashley", "Stephanie", "Emily", "Nicole", "Elizabeth", "Heather", "Melissa", "Michelle", "Kimberly", "Amy", "Angela", "Tiffany", "Rebecca", "Rachel", "Laura", "Courtney", "Amber", "Christina", "Samantha", "Hannah", "Erin", "Katherine", "Megan", "Danielle", "Brittany", "Lauren"]
}

#region initialize
func initialize(ID_COUNTER):
	GENDER = ["male", "female"].pick_random()
	NAME = NAMES[GENDER].pick_random()
	ID = NAME + str(ID_COUNTER)
	STYLE = STYLES.pick_random()
	COLOR = Color(randf_range(0,1), randf_range(0,1), randf_range(0,1))
	var topics = Dialogue.CONVERSATION_NODES.keys()
	for topic in topics:
		OPINIONS[topic] = randi_range(-5,5)
	for style in STYLES:
		OPINIONS[style] = randi_range(-5,5)

	
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

func get_attraction(other_npc):
	var other_style = other_npc.STYLE
	return OPINIONS[other_style]

func score_action(action):
	# score based on need
	action.SCORE += 100-NEEDS[action.NEED]
	if action.SCORE in ["hunger", "energy"]:
		action.SCORE += 10 # bonus for urgent needs

	# score based on preference
	if action.TARGET is NPC:
		if action.TARGET == self:
			action.SCORE = -100
			return action
		action.SCORE += get_opinion(action.TARGET)
		if action.ID == "flirt":
			action.SCORE += get_attraction(action.TARGET)

	# score based on distance
	var total_x
	var total_y
	if action.TARGET is Array:
		total_x = abs(LOCATION[0]- action.TARGET[0])
		total_y = abs(LOCATION[1] - action.TARGET[1])
	else:
		total_x = abs(LOCATION[0] - action.TARGET.LOCATION[0])
		total_y = abs(LOCATION[1] - action.TARGET.LOCATION[1])
	action.SCORE -= total_x + total_y
	

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

func update_relationship(other_npc_id, change):
	if other_npc_id not in RELATIONSHIPS.keys():
		RELATIONSHIPS[other_npc_id] = 0
	RELATIONSHIPS[other_npc_id] += change

func hear_topic(speaker_id, topic, opinion):
	if speaker_id == ID:
		return
	if speaker_id not in RELATIONSHIPS:
		RELATIONSHIPS[speaker_id] = 0
	RECENT_TOPIC = topic
	var this_opinion = OPINIONS[topic]
	var diff = abs(this_opinion - opinion)
	var impression
	if diff < 2:
		update_relationship(speaker_id, 1)
		impression = "pleased"
	elif diff < 4:
		impression = "unimpressed"
	else:
		update_relationship(speaker_id, -1)
		impression = "annoyed"
	return impression


func hear_flirt(speaker_id):
	var npc = Global.NPCS[speaker_id]
	var attraction = get_attraction(npc)
	var impression
	if attraction >= 3:
		update_relationship(speaker_id, 1)
		impression = "pleased"
	elif attraction >=-3:
		impression = "unimpressed"
	else:
		update_relationship(speaker_id, -1)
		impression = "annoyed"
	return impression

#region sprite
func on_hover(npc):
	if npc.ID == ID:
		_on_mouse_entered()
		$DefaultSprite.hide()
		$GlowSprite.show()
		$HoverNameLabel.show()
		
func off_hover(npc):
	if npc.ID == ID:
		$GlowSprite.hide()
		$DefaultSprite.show()
		$HoverNameLabel.hide()


func sprite_clicked() -> void:
	SignalBus.npc_click.emit(self)

func _on_mouse_entered() -> void:
	$DefaultSprite.hide()
	$GlowSprite.show()
	$HoverNameLabel.show()
	#SignalBus.npc_hover.emit(NPC_HOBE)


func _on_mouse_exit() -> void:
	$GlowSprite.hide()
	$DefaultSprite.show()
	$HoverNameLabel.hide()
	#SignalBus.npc_hover_off.emit(self)






#endregion
