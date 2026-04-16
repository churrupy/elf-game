extends Node

#region npcs
signal npc_hover(npc)
signal npc_hover_off(npc)

signal open_npc_menu(npc)
signal keep_open_npc_menu()
signal try_close_npc_menu()
signal close_npc_menu()

signal open_talk_menu(npc)
signal close_talk_menu()

signal open_journal(topic)
signal update_journal()
signal close_journal()

signal toggle_journal(topic)

signal toggle_talk_menu(npc)

signal say_topic(speaker, topic, opinion, location)


#endregion

#region player



#endregion
