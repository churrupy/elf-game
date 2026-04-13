class_name DialogueEvent extends EVENT

var SPEAKER:NPC
var TOPIC:String
var OPINION:int
var TONE:String

var opinion_dict:Dictionary = {
	1: "praised %s",
	0: "commented on %s",
	-1: "mocked %s",

}


func _init(speaker:NPC, topic:String, opinion:int, tone:String = "") -> void:
	TICK = Global.TICKS
	EXPIRES_ON = TICK + 50
	SPEAKER = speaker
	TOPIC = topic
	OPINION = opinion
	TONE = tone
	HEARABLE = true
	LOCATION = speaker.LOCATION

func _to_string() -> String:
	#var npc:NPC = Global.NPCS[SPEAKER_ID]
	var display_list: Array[String] = [
		"[EVENT]",
		SPEAKER.NAME,
		opinion_dict[OPINION] % TOPIC,
		"in a %s tone." %TONE
	]
	var display_string = " ".join(display_list)
	return display_string

func process_reaction(npc:NPC) -> void:
	# does two things (if applicable):
	# creates a witness report
	# creates a relationship memory (whatever i want to call that)
	if npc == SPEAKER: return
	var npc_opinion: int = npc.OPINIONS[TOPIC]
	if OPINION == 0 or npc_opinion == 0: 
		# one person doesn't care when commenting
		# don't create report
		return
	elif OPINION == npc_opinion:
		# share opinion, witness approves of statement
		#var report:WitnessReport = WitnessReport.new(npc, self, 1)
		npc.add_witness_report(self)
		
		var memory_id:String = "share like"
		if OPINION == -1:
			memory_id = "share dislike"
		
		npc.add_relationship_memory(SPEAKER, memory_id)
	else:
		#opposite opinions
		#var report:WitnessReport = WitnessReport.new(npc, self, -1)
		npc.add_witness_report(self)

		var memory_id:String = "likes something I hate"
		if OPINION == -1:
			memory_id = "hates something I like"
		npc.add_relationship_memory(SPEAKER, memory_id)
