class_name FlirtAction extends ACTION

var REQUEST_SENT:bool = false
var EVENT:HistoryEvent = null

func _init(engine, owner:NPC, target:NPC) -> void:
	ID = "flirt"
	super._init(engine, owner, target)

func can_do_action() -> bool:
	return ENGINE.NpcManager.is_available(TARGET)

func tick() -> Array:
	var res:Array = ["running", null]
	if !can_do_action():
		res = ["end", null]
	else:
		res = run()
	OWNER.decay_needs()
	return res
	
	
'''
func run() -> Array:
	if REQUEST_SENT:
		var all_reactions:Array[EventReaction] = ENGINE.History.get_reactions_to_event(EVENT)
		var target_reaction:int = all_reactions.find_custom(func(reaction): return reaction.ACTOR == TARGET.ID)
		
		var response:int = target_reaction.REACTION
		if response == 1:
			pass
		elif response == 0:
			pass
		else:
			pass
	else:
		var params:Dictionary = {
			"verbal": 1,
			"physical": 1
		}

		EVENT = ENGINE.History.add_event(OWNER.ID, "flirt", TARGET.ID, params)

		REQUEST_SENT = true
		return ["running", null]
'''
