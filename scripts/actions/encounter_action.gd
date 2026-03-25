extends RefCounted

class_name EncounterAction extends GenericAction

var ENGINE
var NPC_OWNER

func tick():
    if OWNER.LOCATION == LOCATION:
        do_action()