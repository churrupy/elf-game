class_name RELATIONSHIP extends RefCounted

var OWNER:NPC
var TARGET:NPC

var SCORE:int = 0
var ATTRACTIVE:int

func _init(owner:NPC, target:NPC) -> void:
	OWNER = owner
	TARGET = target

	ATTRACTIVE = OWNER.get_opinion(TARGET.STYLE)

func to_wiki() -> Wiki:
	print("relationship to wiki")
	var new_wiki: Wiki = Wiki.new()
	new_wiki.add_text("{0} thinks".format([OWNER.NAME]))
	new_wiki.add_button(TARGET)
	if ATTRACTIVE != 0:
		new_wiki.add_text("is")
		if ATTRACTIVE == 1:
			new_wiki.add_text("attractive", Color.GREEN)
			# SCORE += 1
		elif ATTRACTIVE == -1:
			new_wiki.add_text("unattractive", Color.RED)
			# SCORE -= 1
		# new_wiki.add_to_wiki("and")
	var likes: Array[String]
	var dislikes: Array[String]
	
	# for op: String in OWNER.OPINIONS.keys():
	# 	if OWNER.OPINIONS[op] == 1:
	# 		likes.append(op)
	# 	elif OWNER.OPINIONS[op] == -1:
	# 		dislikes.append(op)

	# if len(likes) > 0:
	# 	new_wiki.add_to_wiki("likes")
	# 	for op: String in likes:
	# 		var owner_opinion = OWNER.OPINIONS[op]
	# 		var target_opinion = OPINIONS[op]
	# 		if owner_opinion == target_opinion:
	# 			new_wiki.add_to_wiki(op, "button", Color.GREEN)
	# 			SCORE += 1
	# 		elif owner_opinion + target_opinion == 0:
	# 			new_wiki.add_to_wiki(op, "button", Color.RED)
	# 			SCORE -= 1
	# 		else:
	# 			new_wiki.add_to_wiki(op, "button", Color.WHITE)

	# if len(dislikes) > 0:
	# 	new_wiki.add_to_wiki(", and dislikes")
	# 	for op: String in dislikes:
	# 		var owner_opinion = OWNER.OPINIONS[op]
	# 		var target_opinion = OPINIONS[op]
	# 		if owner_opinion == target_opinion:
	# 			new_wiki.add_to_wiki(op, "button", Color.GREEN)
	# 			SCORE += 1
	# 		elif owner_opinion + target_opinion == 0:
	# 			new_wiki.add_to_wiki(op, "button", Color.RED)
	# 			SCORE -= 1
	# 		else:
	# 			new_wiki.add_to_wiki(op, "button", Color.WHITE)
	
	return new_wiki
