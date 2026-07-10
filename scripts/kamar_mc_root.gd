extends Node2D

func _ready() -> void:

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
	if StoryManager.alt2_epilog:
		var player = $Player
		var kubis = $NPC_Kubis
		
		# Nonaktifkan pergerakan
		if player.has_method("set_physics_process"):
			player.set_physics_process(false)
			
		# Posisikan MC (di meja/berdiri)
		if player:
			var node_mc_duduk = get_node_or_null("NodeMCEpilogDuduk")
			if node_mc_duduk:
				player.position = node_mc_duduk.position
			else:
				player.position = Vector2(80, 50)
			if player.has_method("play_custom_animation"):
				player.play_custom_animation("sit_down")
			elif player.has_node("AnimatedSprite2D"):
				player.get_node("AnimatedSprite2D").play("sit_down")
				
		# Posisikan kubis di kasur
		if kubis:
			if kubis.has_method("set_physics_process"):
				kubis.set_physics_process(false)
			if kubis.has_method("set_process"):
				kubis.set_process(false)
			if "is_following_player" in kubis:
				kubis.is_following_player = false
			if "is_moving" in kubis:
				kubis.is_moving = false
				
			var choreo = get_node_or_null("NPCChoreography")
			if choreo:
				choreo.queue_free() # Matikan choreo agar tidak bentrok
				
			var node_kubis = get_node_or_null("NodeKubisEpilogTidur")
			if node_kubis:
				kubis.position = node_kubis.position
			else:
				kubis.position = Vector2(9, 25)
			
			# Hentikan AI dan paksa animasi sleep
			if kubis.has_node("AnimatedSprite2D"):
				kubis.get_node("AnimatedSprite2D").stop()
				kubis.get_node("AnimatedSprite2D").play("sleep")
				
		# Matikan HUD objektif
		var hud = get_node_or_null("/root/ObjectiveHUD")
		if hud:
			hud.hide()
			
		# Dengarkan sinyal dialogic
		if Dialogic.has_signal("signal_event"):
			if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
				Dialogic.signal_event.connect(_on_dialogic_signal)
				
		# Mulai dialog
		if not Dialogic.current_timeline:
			Dialogic.start("alt2_epilog_kamar")

func _on_dialogic_signal(argument: String) -> void:
	if argument == "alt2_mc_tidur":
		var player = $Player
		var kubis = $NPC_Kubis
		if player:
			var node_mc_tidur = get_node_or_null("NodeMCEpilogTidur")
			if node_mc_tidur:
				player.position = node_mc_tidur.position
			else:
				player.position = Vector2(9, 25) # Kasur
			if player.has_method("play_custom_animation"):
				player.play_custom_animation("idle_tidur")
			elif player.has_node("AnimatedSprite2D"):
				player.get_node("AnimatedSprite2D").play("idle_tidur")
			
			player.rotation_degrees = 0 # Pastikan rotasinya normal
		if kubis:
			var node_kubis = get_node_or_null("NodeKubisEpilogTidur")
			if node_kubis:
				kubis.position = node_kubis.position + Vector2(0, -10)
			else:
				kubis.position = Vector2(9, 15) # Samping kepala
