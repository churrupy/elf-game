extends RefCounted

class_name EncounterAction

var ENGINE
var NPC_OWNER


func _init(engine, npc, target_npc):
    ENGINE = engine
    NPC_OWNER = npc
    TARGET_NPC = target_npc