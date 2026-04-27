class_name JoinEvent extends EVENT

var OWNER: NPC
var PARTICIPANT_GROUP: GROUP

func _init(owner:NPC, group:GROUP) -> void:
	TICK = Global.TICKS
	EXPIRES_ON = TICK + 50
	SEEABLE = true
	OWNER = owner
	PARTICIPANT_GROUP = group
	LOCATION = group.get_location()
	TYPE = "converse"
	generate_tags()


func generate_tags() -> void:
	TAGS.append("social")

func is_equal(other_event:EVENT) -> bool:
	if other_event is not JoinEvent: return false
	if self == other_event: return true
	if OWNER != other_event.OWNER: return false
	if PARTICIPANT_GROUP != other_event.PARTICIPANT_GROUP: return false
	return true

func process_involvement(npc:NPC) -> void:
	if npc == OWNER:
		npc.add_witness_report(self, "participant")
	else:
		npc.add_witness_report(self, "witness")
	
func _to_string() -> String:
	var names:Array[String]
	for p:NPC in PARTICIPANT_GROUP.PARTICIPANTS:
		if p == OWNER: continue
		names.append(p.NAME)
	if len(names) > 1:
		names[-1] = "and " + names[-1]
	print(names)
	print(OWNER)
	var str_list:Array[String] = [
		"[{0}]".format([Global.TICKS]),
		OWNER.NAME,
		"joins",
		", ".join(names),
		"at",
		str(PARTICIPANT_GROUP.get_location())
	]
	return " ".join(str_list)

func includes_npc(target:NPC) -> bool:
	if target == OWNER: return true
	if target in PARTICIPANT_GROUP.PARTICIPANTS: return true
	return false

func get_all_participants() -> Array[NPC]:
	var all_p: Array[NPC] = [OWNER]
	all_p += PARTICIPANT_GROUP.PARTICIPANTS
	return all_p

func to_wiki() -> Wiki:
	var new_wiki:Wiki = Wiki.new()
	new_wiki.add_to_wiki("[{0}]".format([Global.TICKS]))
	new_wiki.add_to_wiki(OWNER.ID, "button")
	new_wiki.add_to_wiki("joins")
	for i in range(0, len(PARTICIPANT_GROUP.PARTICIPANTS)):
		if i == len(PARTICIPANT_GROUP.PARTICIPANTS) -1:
			new_wiki.add_to_wiki("and")
		elif i != 0:
			new_wiki.add_to_wiki(",")
		var npc: NPC = PARTICIPANT_GROUP.PARTICIPANTS[i]
		new_wiki.add_to_wiki(npc.ID, "button")
	new_wiki.add_to_wiki("at")
	new_wiki.add_to_wiki(str(PARTICIPANT_GROUP.get_location()))
	new_wiki.add_to_wiki("(I know this doesn't read correctly)")
	return new_wiki
