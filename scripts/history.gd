extends Node

class_name HISTORY_CLASS

var ENGINE
var HISTORY: Array[HistoryEvent]
var REACTIONS: Array[EventReaction]

func _init(engine):
	ENGINE = engine

func _ready() -> void:
	pass


func _process(delta:float):
	pass


func add_event(actor_id:String, action:String, target:String = "", params:Dictionary={}) -> HistoryEvent:
	var actor = Global.NPCS[actor_id]
	var new_event = HistoryEvent.new()
	new_event.ACTOR = actor_id
	new_event.ACTION_ID = action
	new_event.TARGET = target
	new_event.LOCATION = actor.LOCATION
	new_event.TICK = Global.TICKS
	new_event.PARAM = params
	HISTORY.append(new_event)

	var witnesses: Array[String] = ENGINE.NpcManager.get_nearby_npcs(actor.LOCATION)
	for w: String in witnesses:
		add_to_reaction_queue(w, new_event)

	return new_event


func add_to_reaction_queue(npc_id:String, event:HistoryEvent) -> void:
	if npc_id == event.ACTOR:
		return
	var npc = Global.NPCS[npc_id]
	if event not in npc.EVENT_QUEUE:
		npc.EVENT_QUEUE.append(event)


func add_reaction(witness_id:String, reaction:int, event:HistoryEvent) -> void:
	var new_reaction:EventReaction = EventReaction.new()
	new_reaction.TICK = Global.TICKS
	new_reaction.WITNESS = witness_id
	new_reaction.EVENT = event
	new_reaction.REACTION = reaction
	REACTIONS.append(new_reaction)


func add_event_old(npc_id: String, action: String, location: Vector2, witnesses: Array = [], dialogue: String = "") -> void:
	var new_event = HistoryEvent.new()
	new_event.TICK = Global.TICKS
	new_event.NPC_ID = npc_id
	new_event.ACTION_ID = action
	new_event.LOCATION = location
	var index: int = witnesses.find(npc_id)
	if index > -1:
		witnesses.remove_at(index)
	new_event.WITNESSES = witnesses
	new_event.DIALOGUE = dialogue
	HISTORY.append(new_event)


func add_entry(npc, action, location, arg={}):
	if npc is NPC:
		npc = npc.ID
	var history_dict = {
		"tick": Global.TICKS,
		"npc": npc,
		"action": action,
		"location": location,
		"arg": arg
	}
	HISTORY.append(history_dict)


func event_to_string(event:HistoryEvent) -> String:
	var _str:String
	var actor = Global.NPCS[event.ACTOR]
	if event.ACTION_ID == "converse":
		var opinion:int = event.PARAM["opinion"]
		var op_str:String
		if opinion >= 3:
			op_str = "great!"
		elif opinion >= 0:
			op_str = "okay."
		elif opinion >= -3:
			op_str = "lame."
		else:
			op_str = "terrible!"
		_str = "[" + str(event.TICK) + "] " + actor.NAME + ' says, "' + event.PARAM["topic"] + " are " + op_str + '"'
		return _str
	else:
		var str_list: Array[String] = [
			"[" + str(event.TICK) + "] ",
			actor.NAME,
			event.ACTION_ID,
		]
		'''
		if event.TARGET != null:
			var target = Global.NPCS[event.TARGET]
			str_list.append(target.NAME)
		'''
		return " ".join(str_list) + "."

func get_reactions_to_event(event:HistoryEvent) -> Array[EventReaction]:
	return REACTIONS.filter(func(reaction): return reaction.EVENT == event)

func reaction_to_string(reaction:EventReaction) -> String:
	var witness = Global.NPCS[reaction.WITNESS]
	var reaction_dict: Dictionary = {
		1: "pleased",
		0: "indifferent",
		-1: "annoyed"
	}
	var reaction_string:String = reaction_dict[reaction.REACTION]
	var return_string:String = "[" + str(reaction.TICK) + "] " + witness.NAME + " is " + reaction_string + " about this."
	return return_string


func populate_talk_menu(npc_id:String) -> Array[String]:
	'''
	i don't know what i want to show up in the talk menu lol
	'''
	var return_string:Array[String] = []
	var events:Array[HistoryEvent] = HISTORY.filter(func(event): return (event.ACTOR == npc_id or event.TARGET == npc_id) and event.ACTION_ID == "converse")
	for event:HistoryEvent in events:
		return_string.append(event_to_string(event))
		var reaction_list:Array[EventReaction] = get_reactions_to_event(event)
		for reaction:EventReaction in reaction_list:
			return_string.append(reaction_to_string(reaction))
	
	return return_string

func populate_npc_menu(npc_id:String) -> Array[String]:
	var return_string:Array[String] = []
	var events:Array[HistoryEvent] = HISTORY.filter(func(event): return (event.ACTOR == npc_id) or (event.TARGET == npc_id))
	events = events.slice(-5,-1)
	for event:HistoryEvent in events:
		return_string.append(event_to_string(event))
	
	return return_string


func filter_by_actor(npc_id:String) -> Array[HistoryEvent]:
	return HISTORY.filter(func(event): return event.ACTOR == npc_id)

func filter_by_doer(npc_id: String) -> Array[HistoryEvent]:
	# filter by initiator of event
	return HISTORY.filter(func(event): return event.NPC_ID == npc_id)


func filter_by_npc(npc_id: String) -> Array[HistoryEvent]:
	# filter by whether npc is involved in event (whether doer or witness)
	return HISTORY.filter(func(event): return (event.NPC_ID == npc_id) or (npc_id in event.WITNESSES))

func filter_by_npc_old(npc):
	# actions npc is either doer or target
	if npc is NPC:
		npc = npc.ID
	var filtered_history = []
	for h in HISTORY:
		if h["npc"] == npc:
			filtered_history.append(h)
		elif "witnesses" in h["arg"]:
			if npc in h["arg"]["witnesses"]:
				filtered_history.append(h)

	return filtered_history

func filter_by_location(location: Array) -> Array:
	if location == null:
		return []
	return HISTORY.filter(func(event): event.LOCATION == location)

func filter_by_location_old(location):
	if location == null:
		return []
	var filtered_history = []
	for h in HISTORY:
		if h["location"] == location:
			filtered_history.append(h)
	return filtered_history

func history_to_string(history_list: Array =[]) -> Array:
	if history_list == []:
		history_list = HISTORY
	var display_list: Array = []
	for h in history_list:
		var _str: String = "Tick {tick}: {location} {npc} {action}"
		if len(h.WITNESSES) > 0:
			_str += " with {witnesses}"
		_str = _str.format({
			"tick": h.TICK,
			"location": str(h.LOCATION),
			"npc": h.NPC_ID,
			"action": h.ACTION_ID,
			"witnesses": h.WITNESSES
		})
		display_list.append(_str)
	return display_list




func history_to_string_old(history_list = []):
	if history_list == []:
		history_list = HISTORY
	var display_list = []
	for h in history_list:
		var _str = "Tick " + str(h["tick"]) + ": " + str(h["location"]) + " " + h["npc"] + " " + h["action"]
		if "location" in h["arg"]:
			var location_str = " to " + str(h["arg"]["location"])
			_str += location_str
		if "witnesses" in h["arg"]:
			var group_str = " with " + ",".join(h["arg"]["witnesses"]) + "."
			_str += group_str
		'''
		if "dialogue" in h["arg"]:
			var dialogue_str = h["arg"]["dialogue"]
			_str += dialogue_str
		'''
		display_list.append(_str)
	return display_list
