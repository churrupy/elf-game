extends Container

class_name NPC


var NAME: String
var ID: String

var SKIN_COLOR: Color
var HAIR_COLOR: Color
var EYE_COLOR: Color

var PORTRAIT: Dictionary = {}

var LOCATION: Array = [0,0]
var GENDER: String
var ACTION: GenericAction
var RECENT_TOPIC: String
var STYLE: String
var OPINIONS: Dictionary = {}
var RELATIONSHIPS: Dictionary = {}
var NEEDS: Dictionary = {
	"hunger": 50.0,
	"energy": 50.0,
	"release": 50.0,
	"social": 50.0,
	"fun": 50.0,
	"bladder": 50.0,
	"arousal": 0.0
}



var SPRITE
var GLOW_SPRITE
var BUTTON: TextureButton
var GLOW_BUTTON

var STYLES: Array = ["goth", "punk", "prep", "country", "athletic", "queer"]

var NAMES: Dictionary = {
	"male": ["Gerald", "Harry", "Irving", "Jackson", "Kyle", "Leon", "Michael", "Christopher", "Matthew", "Joshua", "David", "James", "Daniel", "Robert", "John", "Joseph", "Andrew", "Justin", "Ryan", "Brandon", "Jason", "William", "Jonathan", "Brian", "Kevin", "Eric", "Nicholas", "Timothy", "Adam", "Anthony", "Thomas", "Steven", "Benjamin", "Mark", "Scott", "Paul"],
	"female": ["Agatha", "Bridget", "Cassidy", "Daniella", "Eve", "Jennifer", "Jessica", "Amanda", "Sarah", "Ashley", "Stephanie", "Emily", "Nicole", "Elizabeth", "Heather", "Melissa", "Michelle", "Kimberly", "Amy", "Angela", "Tiffany", "Rebecca", "Rachel", "Laura", "Courtney", "Amber", "Christina", "Samantha", "Hannah", "Erin", "Katherine", "Megan", "Danielle", "Brittany", "Lauren"]
}

#region initialize
func initialize(ID_COUNTER):
	GENDER = ["male", "female"].pick_random()
	NAME = NAMES[GENDER].pick_random()
	ID = NAME + str(ID_COUNTER)
	STYLE = STYLES.pick_random()
	EYE_COLOR = Color(randf_range(0,1), randf_range(0,1), randf_range(0,1))
	HAIR_COLOR = Color(randf_range(0,1), randf_range(0,1), randf_range(0,1))
	#SKIN_COLOR = Color(randf_range(0,1), randf_range(0.25,0.50), randf_range(0.25,0.75)) # getting WILD in here
	var red = randf_range(0.15, .90)
	var green = red - randf_range(0.05, 0.20)
	green = clamp(green, 0.5, 1.0)
	var blue = green - randf_range(0.05, 0.20)
	blue = clamp(blue, 0.5, 1.0)
	#SKIN_COLOR = Color(randf_range(0.20,0.9), randf_range(0.10,0.75), randf_range(0.05,0.70)) 
	SKIN_COLOR = Color(red, green, blue)

	for part in Constants.PORTRAIT_TEMPLATES.keys():
		var options = Constants.PORTRAIT_TEMPLATES[part]
		PORTRAIT[part] = options.pick_random()


	var topics = Dialogue.CONVERSATION_NODES.keys()
	for topic in topics:
		OPINIONS[topic] = randi_range(-5,5)
	for style in STYLES:
		OPINIONS[style] = randi_range(-5,5)


	

	BUTTON = TextureButton.new()
	add_child(BUTTON)
	BUTTON.texture_normal = load("res://models/npc.png")
	BUTTON.texture_hover = load("res://models/npc_glow.png")
	BUTTON.modulate = HAIR_COLOR

	BUTTON.set_anchors_and_offsets_preset(Control.LayoutPreset.PRESET_CENTER, Control.LayoutPresetMode.PRESET_MODE_MINSIZE, 0)
	#BUTTON.keep_offsets = true
	#BUTTON.set_anchors_preset(Control.LayoutPreset.PRESET_CENTER)
	'''
	var button_size = BUTTON.get_size()
	BUTTON.anchor_left = 0.5
	BUTTON.anchor_right = 0.5
	BUTTON.anchor_top = 0.5
	BUTTON.anchor_bottom = 0.5

	BUTTON.offset_left = -button_size.x / 2
	BUTTON.offset_right = button_size.x / 2
	BUTTON.offset_top = -button_size.y / 2
	BUTTON.offset_bottom = button_size.y / 2
	'''

	BUTTON.pressed.connect(sprite_clicked)
	
	
#endregion
	
#region tick
	
func decay_needs():
	for need in NEEDS:
		var decay = Constants.NEED_DECAY_RATES[need]
		NEEDS[need] = clamp((NEEDS[need] - decay), 0.0, 100.0)


#endregion




#region utility
func _to_string():
	return NAME + " " + str(LOCATION)


#endregion

#region relationships

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

func get_attraction(other_npc):
	return 100 #for testing
	var other_style = other_npc.STYLE
	return OPINIONS[other_style]


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

#endregion

#region sprite

func sprite_clicked() -> void:
	SignalBus.open_npc_menu.emit(self)


#endregion
