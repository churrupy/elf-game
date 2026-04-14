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
var RELATIONSHIPS: Dictionary[String, Array] = {}
var MEMORIES: Array[WitnessReport]

var TAGS: Array[String]
var LIKES: Array[String]
var DISLIKES: Array[String]


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


	generate_tags()
	load_sprites()

	
	
func generate_tags() -> void:
	#TAGS.append(GENDER)
	#TAGS.append(STYLE)

	for topic:String in OPINIONS:
		var score:int = OPINIONS[topic]
		if score > 0:
			#TAGS.append("likes_{0}".format([topic]))
			LIKES.append("likes_{0}".format([topic]))
			DISLIKES.append("dislikes_{0}".format([topic]))
		elif score < 0:
			#TAGS.append("dislikes_{0}".format([topic]))
			LIKES.append("dislikes_{0}".format([topic]))
			DISLIKES.append("likes_{0}".format([topic]))


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

func add_witness_report(event: EVENT, role: String) -> void:
	if is_report_in_memory(event): return
	var report:WitnessReport = WitnessReport.new(self, event, role)
	MEMORIES.append(report)


func is_report_in_memory(event:EVENT) -> bool:
	for m: WitnessReport in MEMORIES:
		if m.EVENT_WITNESSED == event:
			m.TICK = Global.TICKS
			return true
	return false

func add_relationship_memory(speaker:NPC, memory_id: String) -> void:
	if speaker == self: return
	if is_memory_in_relationship(speaker, memory_id): return
	var relationship_memory: RelationshipMemory = RelationshipMemory.new(self, speaker, memory_id)
	if speaker.ID not in RELATIONSHIPS:
		RELATIONSHIPS[speaker.ID] = []
	RELATIONSHIPS[speaker.ID].append(relationship_memory)


func is_memory_in_relationship(speaker:NPC, memory_id: String) -> bool:
	var npc_id: String = speaker.ID
	if npc_id not in RELATIONSHIPS:
		return false
	for mem: RelationshipMemory in RELATIONSHIPS[npc_id]:
		if mem.TARGET == speaker:
			if mem.MEMORY_ID == memory_id:
				mem.update_ticks()
				return true
	return false


func get_opinion(tag: String) -> int:
	if tag in LIKES: return 1
	elif tag in DISLIKES: return -1
	else: return 0




func get_opinion_old(npc_id: String) -> int:
	if npc_id not in RELATIONSHIPS:
		return 0
	var rel_list: Array = RELATIONSHIPS[npc_id]
	var score: int = 0
	for mem: RelationshipMemory in rel_list:
		score += mem.SCORE
	return score

func get_opinion_string(npc_id: String) -> String:
	var opinion_int: int = get_opinion(npc_id)
	if opinion_int > 5:
		return "awesome"
	elif opinion_int > 0:
		return "cool"
	elif opinion_int == 0:
		return "okay"
	elif opinion_int > -5:
		return "obnoxious"
	else:
		return "awful"

func get_impression(npc_id: String) -> Array[String]:
	var impressions: Array[String]
	var other_npc: NPC = Global.NPCS[npc_id]

	if other_npc.STYLE in LIKES:
		impressions.append("is [color=green]attractive[/color]")
	elif other_npc.STYLE in DISLIKES:
		impressions.append("is [color=red]unattractive[/color]")

	for report: WitnessReport in MEMORIES:
		if report.includes_npc(other_npc):
			for reaction:String in report.REACTIONS.keys():
				if report.REACTIONS[reaction] > 0:
					var _str: String = '[color=green]{0}[/color]'.format([reaction])
					if _str not in impressions:
						impressions.append(_str)
				elif report.REACTIONS[reaction] < 0:
					var _str: String = '[color=red]{0}[/color]'.format([reaction])
					if _str not in impressions:
						impressions.append(_str)

	# would like to be able to sort by tag and pair up incongruent tags
	return impressions

	


func get_impression_old(npc_id: String) -> Array[String]:
	# returns list of traits that self thinks of npc
	var impressions: Array[String]
	var other_npc: NPC = Global.NPCS[npc_id]

	var attraction: int = get_attraction(other_npc)
	if attraction > 5:
		impressions.append("very attractive")
	elif attraction > 0:
		impressions.append("attractive")
	elif attraction == 0:
		pass
	elif attraction > -5:
		impressions.append("unattractive")
	else:
		impressions.append("very unattractive")

	#var tone_tracker: Array[String]
	var tone_tracker: Dictionary[String, int]
	var topic_tracker: Dictionary[String, int]
	var action_tracker: Dictionary[String, int]
	 
	for report: WitnessReport in MEMORIES:
		if report.includes_npc(other_npc): 
			var checked_event = report.EVENT_WITNESSED
			if "TONE" in checked_event: # determines their impression of their attitude
				if checked_event.TONE != "":
					if checked_event.TONE not in tone_tracker:
						tone_tracker[checked_event.TONE] = 0
					tone_tracker[checked_event.TONE] += 1
			if "TOPIC" in checked_event: # determines their impression of their likes
				if checked_event.OPINION != 0:
					topic_tracker[checked_event.TOPIC] = checked_event.OPINION
			if checked_event.TYPE not in action_tracker: # determines their impression of their actions
				action_tracker[checked_event.TYPE] = 0
			action_tracker[checked_event.TYPE] += 1

	# process tone
	for tone: String in tone_tracker.keys():
		if tone_tracker[tone] > 5: #sure
			# would eventually have self opinion on action changing the word
			# like if the other npc is bragging, difference between "arrogant" and "confident"	
			impressions.append(tone)

	# process actions
	for action:String in action_tracker.keys():
		if action_tracker[action] > 5:
			if action == "converse": 
				# would eventually have self opinion on action changing the word
				# like if they hate being social, then they'd say "talks to much", or something like that 
				impressions.append("is social")
	
	# process topic
	for topic:String in topic_tracker.keys():
		#var topic_string: String
		var opinion_word:String
		if topic_tracker[topic] > 0:
			opinion_word = "likes"
			#impressions.append("likes %s" % topic)
		elif topic_tracker[topic] < 0:
			opinion_word = "dislikes"
			#impressions.append("dislikes %s" % topic)
		var share_opinion: int = does_share_opinion(topic, topic_tracker[topic])
		var color: String = "white"
		if share_opinion == 1:
			color = "green"
		elif share_opinion == -1:
			color = "red"
		var _str: String = "[color={color}]{opinion} {topic}[/color]".format({
			"color": color,
			"opinion": opinion_word,
			"topic": topic
		})
		impressions.append(_str)

	

	return impressions

func does_share_opinion(topic: String, opinion: int) -> int:
	# MAKE THIS AN ENUM omg
	var this_opinion: int = OPINIONS[topic]
	#if this_opinion == 0 or opinion == 0: return 0
	if this_opinion > 0 and opinion > 0: return 1 # same opinion
	if this_opinion < 0 and opinion < 0: return 1 # same opinion
	if this_opinion > 0 and opinion < 0: return -1
	if this_opinion < 0 and opinion > 0: return -1
	return 0


func get_attraction(other_npc: NPC) -> int:
	#return 100 #for testing
	var other_style = other_npc.STYLE
	return OPINIONS[other_style]


#endregion


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
