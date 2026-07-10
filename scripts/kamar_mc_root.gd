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
			player.position = Vector2(80, 50)
			if player.has_method("play_custom_animation"):
				player.play_custom_animation("idle_up")
				
		# Posisikan kubis di kasur
		if kubis:
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
			player.position = Vector2(9, 25) # Kasur
			if player.has_method("play_custom_animation"):
				player.play_custom_animation("idle_right")
			
			# Putar MC 90 derajat seolah tidur
			player.rotation_degrees = 90
		if kubis:
			kubis.position = Vector2(9, 15) # Samping kepala
