extends Control

class_name Portrait

var BG: ColorRect = ColorRect.new()
var HAIR: TextureRect = TextureRect.new()
var EARS: TextureRect = TextureRect.new()
var BODY: TextureRect = TextureRect.new()
var EYES: TextureRect = TextureRect.new()
var NOSE: TextureRect = TextureRect.new()
var MOUTH: TextureRect = TextureRect.new()
var BANGS: TextureRect = TextureRect.new()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(BG)
	add_child(HAIR)
	add_child(EARS)
	add_child(BODY)
	add_child(EYES)
	add_child(NOSE)
	add_child(MOUTH)
	add_child(BANGS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update(npc:NPC) -> void:
	#$Splash.modulate = npc.HAIR_COLOR
	BG.modulate = npc.HAIR_COLOR
	
	HAIR.texture = load(npc.PORTRAIT["hair"])
	HAIR.modulate = npc.HAIR_COLOR
	
	EARS.texture = load(npc.PORTRAIT["ears"])
	EARS.modulate = npc.SKIN_COLOR

	BODY.texture = load(npc.PORTRAIT["body"])
	BODY.modulate = npc.SKIN_COLOR

	EYES.texture = load(npc.PORTRAIT["eyes"])
	EYES.modulate = npc.EYE_COLOR

	NOSE.texture = load(npc.PORTRAIT["nose"])
	MOUTH.texture = load(npc.PORTRAIT["mouth"])

	BANGS.texture = load(npc.PORTRAIT["bangs"])
	BANGS.modulate = npc.HAIR_COLOR
