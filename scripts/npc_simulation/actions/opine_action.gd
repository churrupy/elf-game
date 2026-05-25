class_name OpineAction extends ACTION

var ACTION_GROUP:GROUP
var REACTION:String

func _init(engine, owner:NPC) -> void:
	ID = "opine"
	ENGINE = engine
	OWNER = owner
	ACTION_GROUP = ENGINE.GroupManager.get_group(OWNER)
	LOCATION = ACTION_GROUP.get_location()
	SEEABLE = true
	HEARABLE = true

#region builder
func create_event() -> OpineAction:
	
	var filter:MEMORY_FILTER = ACTION_GROUP.CURRENT_TOPIC
	filter.set_owner(OWNER)
	var filtered_memories:Array[MEMORY] = filter.run_filter()
	REACTION = OWNER.react_to_memory_list(filtered_memories)
	ENGINE.History.create_event(self)
	return self

#endregion builder

func tick() -> ActionResult:
	var result:ActionResult = run()
	return result

func run() -> ActionResult:
	return ActionResult.new("end")

func _to_string() -> String:
	var str_list:Array[String] = [
		OWNER.NAME,
		"opines."
	]
	return " ".join(str_list)

func get_involved_npcs() -> Array[NPC]:
	return [OWNER]
