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
#var RELATIONSHIPS: Dictionary[String, Impression] = {}
# var MEMORIES: Array[WitnessReport]
var MEMORIES: Array[MEMORY]

var TAGS: Array[String]
var LIKES: Array[String]
var DISLIKES: Array[String]


var NEEDS: Dictionary[String, float] = {
	# "hunger": randf_range(40.0, 90.0),
	"hunger": 40.0,
	"energy": 90.0,
	"release": 90.0,
	"social": 90.0,
	"fun": 90.0,
	"bladder": randf_range(40.0, 90.0),
	# "bladder": 40.0,
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
# var EVENT_QUEUE: Array[EVENT]

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
func initialize():
	GENDER = ["male", "female"].pick_random()
	NAME = NAMES[GENDER].pick_random()
	ID = NAME + str(Global.get_counter())
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
		#OPINIONS[topic] = randi_range(-5,5)
		OPINIONS[topic] = [-1,0,1].pick_random()
	for style in STYLES:
		#OPINIONS[style] = randi_range(-5,5)
		OPINIONS[style] = [-1,0,1].pick_random()


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

#region MEMORIES

func get_known_npcs() -> Array[NPC]:
	var known_npcs:Array[NPC]
	for memory:MEMORY in MEMORIES:
		var action:ACTION = memory.EVENT_ACTION
		var involved_npcs:Array[NPC] = action.get_involved_npcs()
		for npc:NPC in involved_npcs:
			if npc not in known_npcs:
				known_npcs.append(npc)
	return known_npcs

func knows_npc(target:NPC) -> bool:
	var known_npcs:Array[NPC] = get_known_npcs()
	return target in known_npcs

func get_impression_of_npc(npc:NPC) -> Impression:
	var impression: Impression = Impression.new(self, npc)
	if npc.STYLE in LIKES:
		impression.ATTRACTIVE = 1
	elif npc.STYLE in DISLIKES:
		impression.ATTRACTIVE = -1

	var filter:MEMORY_FILTER = MEMORY_FILTER.new().set_owner(self).must_have_npc(npc)
	var memories:Array[MEMORY] = filter.run_filter()

	for memory:MEMORY in memories:
		# fucking something
		pass
	return impression

func get_all_impressions(npc_list:Array[NPC] = []) -> Array[Impression]:
	if len(npc_list) == 0:
		npc_list = get_known_npcs()
	var impression_list:Array[Impression]
	
	for npc:NPC in npc_list:
		var impression:Impression = get_impression_of_npc(npc)
		impression_list.append(impression)
	return impression_list

	# var npc_reports: Array[WitnessReport] = filter_memories_by_npc(npc)
	# # just do likes for now
	# for report: WitnessReport in npc_reports:
	# 	var event: EVENT = report.EVENT_WITNESSED
	# 	if event is DialogueEvent:
	# 		# has topic opinions in it
	# 		if event.TOPIC in impression.OPINIONS.keys():
	# 			# check that opinion is the same
	# 			if impression.OPINIONS[event.TOPIC] == event.OPINION:
	# 				pass
	# 			else:
	# 				# opinion is different somehow
	# 				pass
	# 		else:
	# 			impression.OPINIONS[event.TOPIC] = event.OPINION

	# return impression_list


# func knows_npc(target:NPC) -> bool:
# 	for report: WitnessReport in MEMORIES:
# 	for memory:MEMORY in MEMORIES:
# 		var event:EVENT = report.EVENT_WITNESSED
# 		if event is not StatementEvent: continue
# 		if event.SPEAKER == target: return true
# 	return false

#func filter_memories_by_npc(target:NPC, report_list: Array[WitnessReport] = MEMORIES) -> Array[WitnessReport]:
	#var res_list: Array[WitnessReport]
	#for report: WitnessReport in MEMORIES:
		#if report.includes_npc(target):
			#res_list.append(report)
	#return res_list
#
#func filter_memories_by_event(event: EVENT, report_list: Array[WitnessReport] = MEMORIES) -> Array[WitnessReport]:
	#var res_list: Array[WitnessReport]
	#for report: WitnessReport in MEMORIES:
		#if report.EVENT_WITNESSED == event:
			#res_list.append(report)
	#return res_list
#
#func get_report_wikis(report_list: Array[WitnessReport] = MEMORIES) -> Array[Wiki]:
	#var wiki_list: Array[Wiki]
	#for report:WitnessReport in report_list:
		#var new_wiki: Wiki = report.to_wiki()
		#if new_wiki != null:
			#wiki_list.append(report.to_wiki())
	#return wiki_list

#func get_all_witnessed_npcs(report_list:Array[WitnessReport] = MEMORIES) -> Array[NPC]:
	## returns all npcs that self has witnessed
	#var npc_list: Array[NPC]
	#for report: WitnessReport in report_list:
		#var event: EVENT = report.EVENT_WITNESSED
		#var participants: Array[NPC] = event.get_all_participants()
		#for p:NPC in participants:
			#if p not in npc_list:
				#npc_list.append(p)
	#return npc_list

#func get_impression_of_npc(npc:NPC) -> Impression:
	#var impression: Impression = Impression.new(self, npc)
	#if npc.STYLE in LIKES:
		#impression.ATTRACTIVE = 1
	#elif npc.STYLE in DISLIKES:
		#impression.ATTRACTIVE = -1
#
	#var npc_reports: Array[WitnessReport] = filter_memories_by_npc(npc)
	## just do likes for now
	#for report: WitnessReport in npc_reports:
		#var event: EVENT = report.EVENT_WITNESSED
		#if event is DialogueEvent:
			## has topic opinions in it
			#if event.TOPIC in impression.OPINIONS.keys():
				## check that opinion is the same
				#if impression.OPINIONS[event.TOPIC] == event.OPINION:
					#pass
				#else:
					## opinion is different somehow
					#pass
			#else:
				#impression.OPINIONS[event.TOPIC] = event.OPINION
#
	#return impression

# func get_all_impressions_old() -> Array[Impression]:
# 	var witnessed_npcs: Array[NPC] = get_all_witnessed_npcs()
# 	var impression_list: Array[Impression]
# 	for w:NPC in witnessed_npcs:
# 		var new_impression: Impression = get_impression_of_npc(w)
# 		impression_list.append(new_impression)
# 	return impression_list

#func get_all_impressions(npc_list:Array[NPC] = []) -> Array[Impression]:
	#if npc_list == []:
		#npc_list = get_all_witnessed_npcs()
	#var res_list:Array[Impression]
	#for npc:NPC in npc_list:
		#var impression: Impression = get_impression_of_npc(npc)
		#res_list.append(impression)
	#return res_list

#endregion memories

#region relationships

func create_memory(_action:ACTION) -> void:
	var existing_memory:MEMORY = get_existing_memory(_action)
	if existing_memory != null:
		existing_memory.END_TICK = Global.TICKS
	else:
		var role:String = _action.get_role(self)
		var new_memory:MEMORY = MEMORY.new(_action, self)
		MEMORIES.append(new_memory)

func get_existing_memory(_action:ACTION) -> MEMORY:
	for memory:MEMORY in MEMORIES:
		if _action.is_equal(memory): return memory
	return null

# func requests_response(event:EVENT) -> void:
# 	# adds event to RESPONSE_REQUEST list in SocialAction
# 	SOCIAL_ACTION.RESPONSE_REQUESTS.append(event)

func get_opinion(tag: String) -> int:
	if tag in LIKES: return 1
	elif tag in DISLIKES: return -1
	else: return 0



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

#func get_impression(other_npc: NPC) -> Wiki:
	#var new_wiki: Wiki = Wiki.new()
	#new_wiki.add_to_wiki("{0} thinks".format([NAME]))
	#new_wiki.add_to_wiki(other_npc.ID, "button", Color.WHITE, true)
	#new_wiki.add_to_wiki("is")
	#if other_npc.STYLE in LIKES:
		#new_wiki.add_to_wiki("attractive", "label", Color.GREEN)
	#elif other_npc.STYLE in DISLIKES:
		#new_wiki.add_to_wiki("unattractive", "label", Color.RED)
	#
	#for report: WitnessReport in MEMORIES:
		#if report.includes_npc(other_npc):
			#for reaction: String in report.REACTIONS.keys():
				#if report.REACTIONS[reaction] > 0:
					#new_wiki.add_to_wiki(reaction, "button", Color.GREEN)
				#elif report.REACTIONS[reaction] == 0:
					#new_wiki.add_to_wiki(reaction, "button", Color.WHITE)
				#elif report.REACTIONS[reaction]< 0:
					#new_wiki.add_to_wiki(reaction, "button", Color.RED)
#
	#return new_wiki

	

	
#func get_dialogues() -> Array[String]:
	#var dialogue_list: Array[String]
	#for report:WitnessReport in MEMORIES:
		#dialogue_list.append(report.get_display_string())
	#return dialogue_list


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

func print_state_stack() -> void:
	print("printing stack")
	for action:ACTION in STATE_STACK:
		print(action)


#endregion relationships


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



#region actions
func consume(item:ITEM) -> void:
	print(NAME, " is consuming ", item)
	NEEDS["hunger"] += item.DATA["nutrition"]

func add_response(_action:ACTION) -> void:
	SOCIAL_ACTION.RESPONSE_REQUESTS.append(_action)

func react_to_memory_list(mem_list:Array[MEMORY]) -> String:
	return "likes"


#endregion actions

func get_reserved_locations() -> Array[Vector2]:
	var result_list:Array[Vector2]
	if len(STATE_STACK) == 1:
		return [STATE_STACK[0].LOCATION]
	for action:ACTION in STATE_STACK:
		if action is IdleAction: continue
		result_list.append(action.LOCATION)
	return result_list
