class_name EncounterAction extends ACTION

var ACTIVE: bool = false
var CURRENT_ACTION

func _init(engine, owner:NPC, target:Node= null) -> void:
	ID = "encounter"
	super._init(engine, owner, target)

func tick() -> ActionResult:
	var res: ActionResult = ActionResult.new("running")



	return res


func run() -> ActionResult:
	print("running encounter action")
	var res: ActionResult = ActionResult.new("running")


	# god knows what the fuck goes here



	return res

