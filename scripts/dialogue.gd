extends Node

"""
node types: # not specific in code, but it's good for me to keep track
	- job
	- hobbies
	- values
	- ingredients
	- events/effects
	- people
"""

const CONVERSATION_NODES: Dictionary[String, Array] = {
	"athlete": ["job", "sports", "fitness"],
	"competitiveness": ["sports"],
	"doctor": ["job", "medicine", "illness"],
	"fitness": ["sports", "health"],
	"health": ["fitness", "medicine", "illness", "doctor"],
	"illness": ["health", "doctor", "medicine"],
	"job": ["doctor", "athlete"],
	"medicine": ["health", "doctor"],
	"sports": ["fitness", "competitiveness", "athlete"],	
	
}




const DIALOGUE_STRINGS: Dictionary[String, String] = {
	"sports": "Sports are cool.",
	"fitness": "Fitness is cool.",
	"health": "Health is cool.",
	"competitiveness": "Competitiveness is cool.",
	"medicine": "Medicine is cool.",
	"illness": "Illness sucks.",
	"doctor": "Doctors rock.",
	"athlete": "Athletes rock.",
	"job": "Jobs blow.",
}


func display_topic(topic):
	return DIALOGUE_STRINGS[topic]


func get_next_topic(topic: String):
	if topic == "":
		return DIALOGUE_STRINGS.keys().pick_random()
	else:
		return CONVERSATION_NODES[topic].pick_random()




var ENCOUNTER_STRINGS:Dictionary = {
	"sweet nothings": " whispered sweet nothings to ",
	"kiss neck": " kisses the neck of ",
	"play with nipples": " plays with the nipples of "
}


var ENCOUNTER_ESCALATION:Dictionary = { # what a horrible way to do this lol
	"sweet nothings": "kiss neck",
	"kiss neck": "play with nipples"

}