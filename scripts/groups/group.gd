class_name GROUP extends RefCounted

var PARTICIPANTS: Array[NPC]
var CURRENT_TOPIC:MEMORY_FILTER


func _init(npc_list:Array[NPC]) -> void:
	PARTICIPANTS = npc_list.duplicate()	

func sort() -> void:
	PARTICIPANTS.sort_custom(func(a,b): return a.NAME < b.NAME)


func get_location() -> Vector2:
	# the most average location
	var x: int = 0
	var y: int = 0

	for p:NPC in PARTICIPANTS:
		x += p.LOCATION[0]
		y += p.LOCATION[1]

	x = x/len(PARTICIPANTS)
	y = y/len(PARTICIPANTS)

	var average_location:Vector2 = Vector2(x,y)
	return average_location


func is_equal(other_group:GROUP) -> bool:
	sort()
	other_group.sort()
	return PARTICIPANTS == other_group.PARTICIPANTS


func _to_string() -> String:
	var location:Vector2 = get_location()
	var names:Array = PARTICIPANTS.map(func(npc): return npc.NAME)
	names[-1] = "and " + names[-1]
	var str_list:Array[String] = [
		", ".join(names),
		"are gathered together at",
		str(location)
	]

	return " ".join(str_list)


# func participants_to_string() -> String:
# 	var _str:String = ""
# 	for i in range(0,len(PARTICIPANTS)):
# 		var npc:NPC = PARTICIPANTS[i]
# 		if i == len(PARTICIPANTS) - 1:
# 			_str += "and " + npc.NAME
# 		else:
# 			_str += npc.NAME + ", "
# 	return _str

func to_wiki() -> Wiki:
	var new_wiki:Wiki = Wiki.new()

	new_wiki.add_header("GROUP")

	if len(PARTICIPANTS) <= 1:
		print ("empty group hasn't been cleaned up yet!")
		return new_wiki

	for i in range(0, len(PARTICIPANTS)):
		if i == len(PARTICIPANTS) -1:
			new_wiki.add_text("and")
		elif i != 0:
			new_wiki.add_text(",")
		var npc:NPC = PARTICIPANTS[i]
		new_wiki.add_button(npc)
	
	new_wiki.add_text("talk together at {0}".format([str(get_location())]))
	return new_wiki

func to_wiki_with_focus(focus:NPC) -> Wiki:
	# same information as above but shows from focus's pov
	var new_wiki:Wiki = Wiki.new()

	new_wiki.add_header("GROUP")

	if len(PARTICIPANTS) <= 1:
		print("empty group that hasn't been cleaned up yet!")
		return new_wiki

	new_wiki.add_text("{0} is talking with".format([focus.NAME]))

	var other_npc_list:Array = PARTICIPANTS.filter(func(a): return a != focus)

	for i in range(0, len(other_npc_list)):
		if i == len(other_npc_list) -1:
			new_wiki.add_text("and")
		elif i != 0:
			new_wiki.add_text(",")
		var npc:NPC = other_npc_list[i]
		new_wiki.add_button(npc)
	
	new_wiki.add_text("at {0}".format([str(get_location())]))
	return new_wiki


# func to_wiki() -> Wiki:
# 	if len(PARTICIPANTS) == 0:
# 		print("empty group! shouldn't happen")
# 		push_error("empty group")
# 		return null
# 	elif len(PARTICIPANTS) == 1:
# 		return null
# 	var new_wiki: Wiki = Wiki.new()
# 	new_wiki.add_to_wiki("[{0}]".format([Global.TICKS]))
# 	for i in range(0, len(PARTICIPANTS)):
# 		if i == len(PARTICIPANTS) -1:
# 			new_wiki.add_to_wiki("and")
# 		elif i != 0:
# 			new_wiki.add_to_wiki(",")
# 		var npc: NPC = PARTICIPANTS[i]
# 		new_wiki.add_to_wiki(npc.ID, "button")
# 	new_wiki.add_to_wiki("talk together at")
# 	new_wiki.add_to_wiki(str(get_location()))
# 	return new_wiki