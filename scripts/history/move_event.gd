class_name MoveEvent extends EVENT

var OWNER:NPC

func _init(owner:NPC) -> void:
	TICK = Global.TICKS
	EXPIRES_ON = TICK + 50
	OWNER = owner
	SEEABLE = true
	LOCATION = owner.LOCATION
	TYPE = "move"
	generate_tags()

func generate_tags() -> void:
	TAGS.append("move")

func is_equal(other_event:EVENT) -> bool:
	if other_event is not MoveEvent: return false
	if OWNER == other_event.OWNER:
		if LOCATION == other_event.LOCATION:
			if TICK == other_event.TICK:
				return true
	return false

func _to_string() -> String:
	var str_list:Array[String] = [
		"[{0}]".format([TICK]),
		OWNER.NAME,
		"moves to",
		"[" + str(int(LOCATION[0])) + "," + str(int(LOCATION[1])) + "]"
	]

	return " ".join(str_list)

func process_involvement(npc:NPC) -> void:
	if npc == OWNER:
		npc.add_witness_report(self, "participant")
	else:
		npc.add_witness_report(self, "witness")

func includes_npc(target:NPC) -> bool:
	return OWNER == target

func get_all_participants() -> Array[NPC]:
	return [OWNER]

func to_wiki() -> Wiki:
	var new_wiki: Wiki = Wiki.new()
	new_wiki.add_to_wiki("[{0}]".format([TICK]))

	new_wiki.add_to_wiki(OWNER.ID, "button")
	new_wiki.add_to_wiki("moves to")
	var vector_string:String = "[" + str(int(LOCATION[0])) + "," + str(int(LOCATION[1])) + "]"
	new_wiki.add_to_wiki(vector_string)
	
	return new_wiki
