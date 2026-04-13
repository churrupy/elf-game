class_name NPC extends Container

#region constants
# i'll change this eventually
# yeet you into an xml file
var STYLES: Array = ["goth", "punk", "prep", "country", "athletic", "queer"]

var NAMES: Dictionary = {
	"male": ["Gerald", "Harry", "Irving", "Jackson", "Kyle", "Leon", "Michael", "Christopher", "Matthew", "Joshua", "David", "James", "Daniel", "Robert", "John", "Joseph", "Andrew", "Justin", "Ryan", "Brandon", "Jason", "William", "Jonathan", "Brian", "Kevin", "Eric", "Nicholas", "Timothy", "Adam", "Anthony", "Thomas", "Steven", "Benjamin", "Mark", "Scott", "Paul"],
	"female": ["Agatha", "Bridget", "Cassidy", "Daniella", "Eve", "Jennifer", "Jessica", "Amanda", "Sarah", "Ashley", "Stephanie", "Emily", "Nicole", "Elizabeth", "Heather", "Melissa", "Michelle", "Kimberly", "Amy", "Angela", "Tiffany", "Rebecca", "Rachel", "Laura", "Courtney", "Amber", "Christina", "Samantha", "Hannah", "Erin", "Katherine", "Megan", "Danielle", "Brittany", "Lauren"]
}

#endregion constants

#region data
var NAME: String
var ID: String

var SKIN_COLOR: Color
var HAIR_COLOR: Color
var EYE_COLOR: Color

var PORTRAIT: Dictionary = {}

var LOCATION: Vector2
var GENDER: String
var CURRENT_ACTION: ACTION
var RECENT_TOPIC: String
var STYLE: String
var OPINIONS: Dictionary = {}
var RELATIONSHIPS: Dictionary = {}
var MEMORIES: Array[WitnessReport]


var NEEDS: Dictionary = {
	"hunger": 50.0,
	"energy": 50.0,
	"release": 10.0,
	"social": 50.0,
	"fun": 50.0,
	"bladder": 50.0,
	"arousal": 0.0
}

#endregion


#region sprite
var SPRITE: Sprite2D = Sprite2D.new()
var GLOW_SPRITE: Sprite2D = Sprite2D.new()
var BUTTON: TextureButton
var GLOW_BUTTON
var NPC_BUTTON: Button = Button.new()

var MENU_OPEN: bool = false # tracks whether npc glows

var DIRECTION: Vector2
var DIRECTION_LABEL: Label = Label.new()

var LOOKING_AT: Array[Vector2]



#endregion sprite

#region actions
var EVENT_QUEUE: Array[EVENT]

var STATE_STACK: Array[ACTION] = []
var SOCIAL_ACTION: SocialAction_new

#endregion actions



func _draw()->void:
	var direction_angle: float = DIRECTION.angle()
	var start_angle: float = direction_angle + (PI/2)
	var end_angle: float = direction_angle - (PI/2)
	draw_arc(LOCATION, Constants.TILE_SIZE, start_angle, end_angle, 20, HAIR_COLOR)
	for v: Vector2 in LOOKING_AT:
		var direction: Vector2 = LOCATION.direction_to(v) * Constants.TILE_SIZE
		draw_line(LOCATION, direction, HAIR_COLOR, 5.0)

#region initialize
func initialize(ID_COUNTER):
	GENDER = ["male", "female"].pick_random()
	NAME = NAMES[GENDER].pick_random()
	ID = NAME + str(ID_COUNTER)
	STYLE = STYLES.pick_random()
	EYE_COLOR = Color(randf_range(0,1), randf_range(0,1), randf_range(0,1))
	HAIR_COLOR = Color(randf_range(0,1), randf_range(0,1), randf_range(0,1))
	
	var red = randf_range(0.15, .90)
	var green = red - randf_range(0.05, 0.20)
	green = clamp(green, 0.5, 1.0)
	var blue = green - randf_range(0.05, 0.20)
	blue = clamp(blue, 0.5, 1.0)
	SKIN_COLOR = Color(red, green, blue)

	for part in Constants.PORTRAIT_TEMPLATES.keys():
		var options = Constants.PORTRAIT_TEMPLATES[part]
		PORTRAIT[part] = options.pick_random()


	var topics = Dialogue.CONVERSATION_NODES.keys()
	for topic in topics:
		OPINIONS[topic] = randi_range(-5,5)
	for style in STYLES:
		OPINIONS[style] = randi_range(-5,5)


	load_sprites()

	
	
	
func load_sprites() -> void:
	SPRITE.texture = load("res://models/npc.png")
	SPRITE.modulate = HAIR_COLOR
	add_child(SPRITE)

	GLOW_SPRITE.texture = load("res://models/npc_glow.png")
	GLOW_SPRITE.modulate = HAIR_COLOR
	GLOW_SPRITE.hide()
	add_child(GLOW_SPRITE)
	
	

	
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

func add_witness_report(report: WitnessReport) -> void:
	if not already_reacted(report.EVENT):
		MEMORIES.append(report)

func already_reacted(event:EVENT) -> bool:
	for m: WitnessReport in MEMORIES:
		if m.EVENT == event:
			m.TICK = Global.TICKS
			return true
	return false

func update_relationship(other_npc_id, change):
	if other_npc_id not in RELATIONSHIPS.keys():
		RELATIONSHIPS[other_npc_id] = 0
	RELATIONSHIPS[other_npc_id] += change


func hear_topic(speaker_id: String, topic: String, opinion: int) -> String:
	if speaker_id == ID:
		return ""
	if speaker_id not in RELATIONSHIPS:
		RELATIONSHIPS[speaker_id] = 0
	RECENT_TOPIC = topic
	SOCIAL_ACTION.RECENT_TOPIC = topic
	var this_opinion: int = OPINIONS[topic]
	var diff: int = abs(this_opinion - opinion)
	var impression: String
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



func get_journal_entry() -> Array[String]:
	var display_list: Array[String] = []
	var _str = "Name: " + NAME
	display_list.append(_str)

	_str = "ID: " + ID
	display_list.append(_str)

	_str = "Gender: " + GENDER
	display_list.append(_str)

	for need in NEEDS:
		_str = need.capitalize() + ": " + str(int(NEEDS[need]))
		display_list.append(_str)
	
	return display_list

func update_direction(new_direction:Vector2) -> void:
	new_direction = new_direction.sign()
	DIRECTION = new_direction
	var direction_text:String

	if new_direction[0] < 0:
		direction_text = "L"
	elif new_direction[0] > 0:
		direction_text = "R"
	elif new_direction[1] < 0:
		direction_text = "U"
	elif new_direction[1] > 0:
		direction_text = "D"
	else:
		return # retain original direction
		#direction_text = "X"
	DIRECTION_LABEL.text = direction_text
