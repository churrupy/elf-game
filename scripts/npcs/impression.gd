class_name Impression extends RefCounted

var OWNER: NPC
var TARGET: NPC

var ATTRACTIVE: int = 0
var OPINIONS: Dictionary[String, int]

func _init(owner: NPC, target: NPC) -> void:
	OWNER = owner
	TARGET = target

func to_wiki() -> Wiki:
	var new_wiki: Wiki = Wiki.new()
	new_wiki.add_to_wiki("{0} thinks".format([OWNER.NAME]))
	new_wiki.add_to_wiki(TARGET.ID, "button", Color.WHITE, true)
	if ATTRACTIVE != 0:
		new_wiki.add_to_wiki("is")
		if ATTRACTIVE == 1:
			new_wiki.add_to_wiki("attractive", "label", Color.GREEN)
		elif ATTRACTIVE == -1:
			new_wiki.add_to_wiki("unattractive", "label", Color.RED)
		new_wiki.add_to_wiki("and")
	var likes: Array[String]
	var dislikes: Array[String]
	
	for op: String in OPINIONS.keys():
		if OPINIONS[op] == 1:
			likes.append(op)
		elif OPINIONS[op] == -1:
			dislikes.append(op)

	if len(likes) > 0:
		new_wiki.add_to_wiki("likes")
		for op: String in likes:
			var owner_opinion = OWNER.OPINIONS[op]
			var target_opinion = OPINIONS[op]
			if owner_opinion == target_opinion:
				new_wiki.add_to_wiki(op, "button", Color.GREEN)
			elif owner_opinion + target_opinion == 0:
				new_wiki.add_to_wiki(op, "button", Color.RED)
			else:
				new_wiki.add_to_wiki(op, "button", Color.WHITE)

	if len(dislikes) > 0:
		new_wiki.add_to_wiki(", and dislikes")
		for op: String in dislikes:
			var owner_opinion = OWNER.OPINIONS[op]
			var target_opinion = OPINIONS[op]
			if owner_opinion == target_opinion:
				new_wiki.add_to_wiki(op, "button", Color.GREEN)
			elif owner_opinion + target_opinion == 0:
				new_wiki.add_to_wiki(op, "button", Color.RED)
			else:
				new_wiki.add_to_wiki(op, "button", Color.WHITE)
	
	return new_wiki
