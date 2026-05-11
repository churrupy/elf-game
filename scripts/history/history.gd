class_name HISTORY_CLASS extends Control

var ENGINE
var HISTORY: Array[EVENT_new]


func _init(engine):
	ENGINE = engine

func add_event() -> void:
	# steps
	# create event
	# populate event information
	# check that event doesn't already exist
	# add event
	pass

func create_event(_action:ACTION) -> void:
	var existing_event:EVENT_new = get_existing_event(_action)
	if existing_event != null:
		# do something
		existing_event.END_TICK = Global.TICKS
	else:
		var new_event:EVENT_new = EVENT_new.new(_action)
		#var current_room:ROOM = ENGINE.Map.get_room(new_event.LOCATION)
		#new_event.ROOM = current_room
		HISTORY.append(new_event)
	
	broadcast_action(_action)

func get_existing_event(_action:ACTION) -> EVENT_new:
	for event:EVENT_new in HISTORY:
		if _action.is_equal(event): return event
	return null

	

func broadcast_action(_action:ACTION) -> void:
	var _witnesses:Array[NPC]

	if _action.HEARABLE:
		var filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().in_range_of(_action.OWNER.LOCATION, 2)
		var hearing_npcs:Array[NPC] = filter.run_filter()
		_witnesses += hearing_npcs
	
	if _action.SEEABLE:
		var filter:NPC_FILTER = NPC_FILTER.new(ENGINE).set_list().in_range_of(_action.OWNER.LOCATION, 10).looking_at()
		var seeing_npcs:Array[NPC] = filter.run_filter()
		_witnesses += seeing_npcs

	var witness_list:Array[NPC]
	for npc:NPC in _witnesses:
		if npc not in witness_list:
			npc.create_memory(_action)
			# event.process_involvement(npc)
			witness_list.append(npc)

#region add event
# god i gotta fix this somehow

#func add_statement_event(speaker:NPC, target:NPC=null, tone:String = "") -> bool:
	#var statement_event:StatementEvent = StatementEvent.new(speaker, target, tone)
	#var added:bool = add_event(statement_event)
	#if !added: return false
#
	#ENGINE.NpcManager.broadcast_event(statement_event)
	#return true
#
#func add_prompt_event(speaker:NPC, target:NPC, tone:String = "") -> bool:
	#var prompt_event:PromptEvent = PromptEvent.new(speaker, target, tone)
	#var added:bool = add_event(prompt_event)
	#if !added: return false
#
	#ENGINE.NpcManager.broadcast_event(prompt_event)
	#return true

#func add_introduce_event(speaker: NPC, target: NPC, tone: String = "") -> void:
	##add_conversation_event(speaker)
#
	#var introduction_event: IntroductionEvent = IntroductionEvent.new(speaker, target, tone)
	#add_event(introduction_event)
#
	##HISTORY.append(introduction_event)
	#ENGINE.NpcManager.broadcast_event(introduction_event)
#
#func add_dialogue_event(speaker: NPC, topic:String, opinion:int, tone:String="") -> void:
	##add_conversation_event(speaker)
	#print("dialogue event being added")
	#var dialogue_event: DialogueEvent = DialogueEvent.new(speaker, topic, opinion, tone) 
	#add_event(dialogue_event)
	##HISTORY.append(dialogue_event)
	#ENGINE.NpcManager.broadcast_event(dialogue_event)
#
#func add_conversation_event(group:GROUP) -> void:
	#var conversation_event:ConversationEvent = ConversationEvent.new(group)
	#add_event(conversation_event)
	#ENGINE.NpcManager.broadcast_event(conversation_event)

# func add_conversation_event(event) -> void:
# 	# will eventually update to take the center of conversation, not the speaker
# 	var convo_partners_ids: Array[String] = ENGINE.NpcManager.get_conversation_partners(speaker)
# 	var convo_partners: Array[NPC]
# 	for npc_id: String in convo_partners_ids:
# 		convo_partners.append(Global.NPCS[npc_id])
	
# 	convo_partners.append(speaker) 
# 	# lol at removing speaker and then adding them back in
	
# 	var conversation_event: ConversationEvent = ConversationEvent.new(convo_partners)
# 	add_event(conversation_event)
# 	ENGINE.NpcManager.broadcast_event(conversation_event)

#func add_join_event(npc:NPC, group:GROUP) -> void:
	#var join_event:JoinEvent = JoinEvent.new(npc, group)
	#add_event(join_event)
	#ENGINE.NpcManager.broadcast_event(join_event)
#
#func add_leave_event(npc:NPC, group:GROUP) -> void:
	#pass
#
#func add_move_event(owner:NPC) -> void:
	#var move_event:MoveEvent = MoveEvent.new(owner)
	#add_event(move_event)
	#ENGINE.NpcManager.broadcast_event(move_event)

#func add_event(event: EVENT) -> bool:
	## checks if event is already in list
	#for checked_event: EVENT in HISTORY:
		#if checked_event.is_equal(event): return false
	#HISTORY.append(event)
	#return true

#endregion add events


func populate_talk_menu(npc_id:String) -> Array[String]:
	return []
	#'''
	#i don't know what i want to show up in the talk menu lol
	#'''
	#var return_string:Array[String] = []
	#var events:Array[EVENT] = HISTORY.filter(func(event): return (event.ACTOR == npc_id or event.TARGET == npc_id))
	#for event:EVENT in events:
		#return_string.append(event_to_string(event))
		#var reaction_list:Array[EventReaction] = get_reactions_to_event(event)
		#for reaction:EventReaction in reaction_list:
			#pass
			##return_string.append(reaction_to_string(reaction))
	#
	#return return_string

func populate_npc_menu(npc_id:String) -> Array[String]:
	return []
	#var return_string:Array[String] = []
	#var events:Array[EVENT] = HISTORY.filter(func(event): return (event.ACTOR == npc_id) or (event.TARGET == npc_id))
	#events = events.slice(-5,-1)
	#for event:EVENT in events:
		#return_string.append(event_to_string(event))
	#
	#return return_string


func does_event_exist(actor_id:String, action_id:String, target_id:String) -> int:
	var event_index:int = HISTORY.find_custom(func(event): return event.ACTOR==actor_id and event.ACTION_ID == action_id and event.TARGET == target_id)
	return event_index
	


func event_strings(history_list:Array[EVENT_new] = HISTORY) -> Array[String]:
	var display_list:Array[String]
	for event:EVENT_new in history_list:
		display_list.append(str(event))
	return display_list

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
 
