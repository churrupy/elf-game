class_name EVENT_new extends RefCounted

var TICK:int

var TYPE:String

var SPEAKER:NPC
var TARGET:NPC
var TONE:String

var SEEABLE:bool = false
var HEARABLE:bool = false

var SEEN_BY:Array[NPC] = []
var HEARD_BY:Array[NPC] = []

var request:bool = false

#region builder

func _init(type:String) -> void:
    TICK = Global.TICKS
    TYPE = type

func add_speaker(_speaker:NPC) -> EVENT:
    SPEAKER = _speaker
    return self

func add_target(_target:NPC) -> EVENT:
    TARGET = _target
    return self

func add_tone(_tone:String) -> EVENT:
    TONE = _tone
    return self

func get_request() -> EVENT:
    request = true
    return self

func is_hearable() -> EVENT:
    var filter:NPC_FILTER = NPC_FILTER.new().set_list(NPCS).in_range_of(event.LOCATION, 2)
    HEARD_BY = filter.run_filter()
    return self

func is_seeable() -> EVENT:
    var filter:NPC_FILTER = NPC_FILTER.new().set_list(NPCS).in_range_of(event.LOCATION, 10).looking_at()
    SEEN_BY = filter.run_filter()
    return self

#endregion builder

func get_all_participants() -> Array[NPC]:
    var participants:Array[NPC]
    if SPEAKER != null:
        participants.append(SPEAKER)

func includes_npc(target:NPC) -> bool:
    return target in get_all_participants()

func broadcast() -> void:
    if SPEAKER != null:
        SPEAKER.add_witness_report(self, "participant")
    
    for npc:NPC in HEARD_BY:
        npc.add_witness_report(self, "witness")
    
    for npc:NPC in SEEN_BY:
        npc.add_witness_report(self, "witness")

# func process_involvement(npc:NPC) -> void:
#     if SPEAKER != null:
#         if npc == SPEAKER:
#             npc.add_witness_report(self, "participant")
#             return 
    
#     if npc in HEARD_BY or npc in SEEN_BY:
#         npc.add_witness_report(self,"witness")

func _to_string() -> String:
    var display_list:Array[String]
    display_list.append("[{0}]".format([TICK]))
    if SPEAKER != null:
        display_list.append(SPEAKER.NAME)
    


func _to_string() -> String:
	var display_list: Array[String] = [
		"[{0}]".format([TICK]),
		SPEAKER.NAME,
		"introduces themselves to",
		TARGET.NAME,
		"in a {0} tone.".format([TONE])
	]

	var display_string:String = " ".join(display_list)
	return display_string

func to_wiki() -> Wiki:
    var new_wiki: Wiki = Wiki.new()
	new_wiki.add_to_wiki("[{0}]".format([TICK]))
    if SPEAKER != null:
	    new_wiki.add_to_wiki(SPEAKER.ID, "button", Color.WHITE, true)
	new_wiki.add_to_wiki("introduces themselves to")
	new_wiki.add_to_wiki(TARGET.ID, "button", Color.WHITE, true)
    if TONE != null:
	    new_wiki.add_to_wiki("in a")
	    new_wiki.add_to_wiki(TONE, "button")
	    new_wiki.add_to_wiki("tone")
	return new_wiki
