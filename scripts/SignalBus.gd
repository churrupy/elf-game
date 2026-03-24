extends Node

signal tick_signal()

#region npcs
signal npc_hover(npc)
signal npc_hover_off(npc)
signal npc_click(npc)
signal close_npc_menu()
signal talk_to_npc(npc)
signal close_talk_menu()

signal say_topic(speaker, topic, opinion, location)


#endregion

#region player
signal player_move_request(location)



#endregion
