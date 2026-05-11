class_name MEMORY extends EVENT_new

# same as event but specifically for npcs to track them witnessing an action

var OWNER:NPC
var ROLE:String

func _init(_action:ACTION, owner:NPC) -> void:
	OWNER = owner
	ROLE = _action.get_role(owner)
	super._init(_action)
