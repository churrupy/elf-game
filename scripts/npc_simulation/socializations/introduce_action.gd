class_name IntroduceAction extends ACTION

func score() -> IntroduceAction:
	var owner_group:GROUP = ENGINE.GroupManager.get_group(OWNER)
	for p:NPC in owner_group.PARTICIPANTS:
		if p == OWNER: continue
		var rel:RELATIONSHIP = ENGINE.RelationshipManager.get_relationship(OWNER, p)
		if rel == null:
			SCORE = 1
			return self
		# if !OWNER.knows_npc(p):
		# 	SCORE = 1
		# 	return self
	SCORE = 0
	return self

func set_id() -> void:
	ID = "IntroduceAction"

func run() -> ActionResult:
	ENGINE.History.add_event(self)
	var owner_group:GROUP = ENGINE.GroupManager.get_group(OWNER)
	for p:NPC in owner_group.PARTICIPANTS:
		if p == OWNER: continue
		var rel:RELATIONSHIP = ENGINE.RelationshipManager.get_relationship(OWNER, p)

		if rel == null:
			ENGINE.RelationshipManager.create_relationship(OWNER, p)
			# create introduction memory
		
		rel = ENGINE.RelationshipManager.get_relationship(p, OWNER)
		if rel == null:
			ENGINE.RelationshipManager.create_relationship(p, OWNER)
			# create introduction memory
			
		# if ENGINE.RelationshipManager.
		# if !p.knows_npc(OWNER):
		# 	p.create_memory(self)
		# if !OWNER.knows_npc(p):
		# 	OWNER.create_memory(self)
	STATUS = "success"
	return ActionResult.new("end turn")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"introduces themselves to the group."
	]
	return " ".join(str_list)