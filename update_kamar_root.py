import os

filepath = 'scripts/kamar_mc_root.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_logic = '''
	# Ending C: Kubis lenyap dan setup awal
	if StoryManager.is_kubis_lenyap:
		var kubis_node = get_node_or_null("NPC_Kubis")
		if kubis_node:
			kubis_node.queue_free()
	
	if StoryManager.ending_c_state == "epilog":
		var player = $Player
		var aloha = $NPC_Aloha
		if player:
			var node_mc_tidur = get_node_or_null("NodeMCEpilogTidur")
			if node_mc_tidur:
				player.position = node_mc_tidur.position
			else:
				player.position = Vector2(9, 25)
			if player.has_method("play_custom_animation"):
				player.play_custom_animation("idle_tidur")
			elif player.has_node("AnimatedSprite2D"):
				player.get_node("AnimatedSprite2D").play("idle_tidur")
		
		if aloha:
			aloha.hide() # Akan muncul via signal aloha_fade_in
			var pos_aloha = get_node_or_null("PosisiAloha_Hari2_DekatKasur")
			if pos_aloha:
				aloha.position = pos_aloha.position
				
		var hud = get_node_or_null("/root/ObjectiveHUD")
		if hud:
			hud.hide()
			
		if not Dialogic.current_timeline:
			Dialogic.start("ending_c_epilog")
		return
'''

for i, line in enumerate(lines):
    if 'if StoryManager.alt2_epilog:' in line:
        lines.insert(i, new_logic)
        break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Updated kamar_mc_root.gd")
