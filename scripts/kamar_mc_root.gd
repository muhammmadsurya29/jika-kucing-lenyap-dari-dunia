extends Node2D

func _ready() -> void:
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
				player.play_custom_animation("idle_up")
				
		# Posisikan kubis di kasur
		if kubis:
			var node_kubis = get_node_or_null("NodeKubisEpilogTidur")
			if node_kubis:
				kubis.position = node_kubis.position
			else:
				kubis.position = Vector2(9, 25)
			if kubis.has_node("AnimatedSprite2D"):
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
