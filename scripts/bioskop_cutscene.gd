extends Node2D

@onready var mantan = $NPC_Mantan
@onready var player = $Player

func _ready() -> void:
	var dark_mod = CanvasModulate.new()
	dark_mod.color = Color("262a42") # Warna gelap malam/bioskop
	add_child(dark_mod)
	
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	# Mulai cutscene otomatis begitu masuk
	if not Dialogic.current_timeline:
		if StoryManager.current_day == 101:
			DialogicHelper.play_vn("ending_c_dalam_bioskop")
		elif StoryManager.current_day == 100:
			# Posisikan seolah sudah duduk
			player.position.y -= 20
			mantan.position.y -= 20
			DialogicHelper.play_vn("alt2_dalam_bioskop")
		else:
			DialogicHelper.play_vn("hari2_malam_bioskop")

func _on_dialogic_signal(argument: String) -> void:
	if argument == "mc_serahkan_dvd":
		# Animasi sederhana, misal player hadap mantan
		if player.has_method("play_custom_animation"):
			player.play_custom_animation("idle_right")
		if mantan.has_node("AnimatedSprite2D"):
			mantan.get_node("AnimatedSprite2D").play("idle_left")
	elif argument == "mc_masuk_duduk":
		# Animasi jalan ke atas seolah duduk
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(player, "position:y", player.position.y - 20, 1.0)
		tween.tween_property(mantan, "position:y", mantan.position.y - 20, 1.0)
	elif argument == "kembali_ke_kamar":
		var sm = get_node_or_null("/root/StoryManager")
		if sm:
			sm.ganti_hari("res://scenes/maps/kamar_mc.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
