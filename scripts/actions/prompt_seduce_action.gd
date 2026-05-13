class_name PromptSeduceAction extends ACTION

func _init(engine, owner:NPC) -> void:
	ID = "prompt seduce"
	ENGINE = engine
	OWNER = owner
	LOCATION = owner.LOCATION
	HEARABLE = true

func set_target(target:NPC) -> PromptSeduceAction:
	TARGET = target
	TARGET.add_response(self)
	return self

func create_event() -> PromptIntroduceAction:
	ENGINE.History.create_event(self)