extends Node2D

class_name NPC

signal sprite_pressed_signal


var NAME
var ID
var COLOR
var LOCATION = [0,0]
var GENDER
var ACTION
var NEEDS = {
	"hunger": 50,
	"energy": 50,
	"release": 50,
	"social": 50,
	"fun": 50,
	"bladder": 50
}

var NAMES = {
	"male": ["Gerald", "Harry", "Irving", "Jackson", "Kyle", "Leon", "Michael", "Christopher", "Matthew", "Joshua", "David", "James", "Daniel", "Robert", "John", "Joseph", "Andrew", "Justin", "Ryan", "Brandon", "Jason", "William", "Jonathan", "Brian", "Kevin", "Eric", "Nicholas", "Timothy", "Adam", "Anthony", "Thomas", "Steven", "Benjamin", "Mark", "Scott", "Paul"],
	"female": ["Agatha", "Bridget", "Cassidy", "Daniella", "Eve", "Jennifer", "Jessica", "Amanda", "Sarah", "Ashley", "Stephanie", "Emily", "Nicole", "Elizabeth", "Heather", "Melissa", "Michelle", "Kimberly", "Amy", "Angela", "Tiffany", "Rebecca", "Rachel", "Laura", "Courtney", "Amber", "Christina", "Samantha", "Hannah", "Erin", "Katherine", "Megan", "Danielle", "Brittany", "Lauren"]
}

#region initialize
func initialize(ID_COUNTER):
	GENDER = ["male", "female"].pick_random()
	NAME = NAMES[GENDER].pick_random()
	ID = NAME + str(ID_COUNTER)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	COLOR = Color(randf_range(0,1), randf_range(0,1), randf_range(0,1))
	$DefaultSprite.modulate = COLOR
	$GlowSprite.modulate = COLOR
	$HoverNameLabel.text = NAME
	#$HoverNameLabel.modulate = COLOR
	#$HoverNameLabel.add_theme_color_override("font_outline_color",Color.BLACK)
	hide()
	$GlowSprite.hide()
	$HoverNameLabel.hide()
	SignalBus.npc_hover.connect(on_hover)
	SignalBus.npc_hover_off.connect(off_hover)
	
func on_hover(npc):
	if npc == self:
		$DefaultSprite.hide()
		$GlowSprite.show()
		$HoverNameLabel.show()
		#print("hovering!")
		
func off_hover(npc):
	if npc == self:
		$GlowSprite.hide()
		$DefaultSprite.show()
		$HoverNameLabel.hide()
	
#endregion
	
#region tick
func tick():
	#move_random()
	decay_needs()
	clamp_needs()
	
func decay_needs():
	for need in NEEDS:
		var decay = Constants.NEED_DECAY_RATES[need]
		NEEDS[need] -= decay

func clamp_needs():
	for need in NEEDS:
		NEEDS[need] = clamp(NEEDS[need], 0, 100)
		

func move_random():
	#print("npc called")
	var direction_options = [
		Vector2(Constants.TILE_SIZE, 0),
		Vector2(-Constants.TILE_SIZE, 0),
		Vector2(0, Constants.TILE_SIZE),
		Vector2(0, -Constants.TILE_SIZE)
	]
	var direction = direction_options.pick_random()
	position += direction
	position = position.clamp(Vector2.ZERO, Constants.SCREEN_SIZE)


#endregion

#region AI
func get_opinion(other_npc):
	# dummy function
	return randi_range(-5, 5)

func score_action(action):
	# score based on need
	action.SCORE += 100-NEEDS[action.NEED]
	if action.SCORE in ["hunger", "energy"]:
		action.SCORE += 10 # bonus for urgent needs

	# score based on preference
	if action.FOLLOWING != null:
		action.SCORE += get_opinion(action.FOLLOWING)

	# score based on distance
	var total_x = abs(LOCATION[0]- action.TARGET.LOCATION[0])
	var total_y = abs(LOCATION[1] - action.TARGET.LOCATION[1])
	action.SCORE -= total_x #distance is penalty
	action.SCORE -= total_y

	return action

	
#endregion



#region NEEDS
func has_urgent_needs():
	if NEEDS["hunger"] < 50:
		return true
	if NEEDS["energy"] < 50:
		return true
	return false


#endregion


#region utility
func _to_string():
	return NAME + " " + str(LOCATION)


#endregion


func sprite_clicked() -> void:
	SignalBus.npc_click.emit(self)

func _on_mouse_entered() -> void:
	SignalBus.npc_hover.emit(self)


func _on_mouse_exit() -> void:
	SignalBus.npc_hover_off.emit(self)
