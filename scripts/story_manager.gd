extends Node

# Script Global (Autoload) untuk manajemen alur cerita dan state game

var current_day: int = 0
var can_sleep: bool = false
var can_leave_room: bool = false
var cafe_event_done: bool = false
var is_night: bool = false
var day4_state: String = ""
var alt2_post_bioskop: bool = false
var alt2_epilog: bool = false
var is_ending_c: bool = false
var is_kubis_lenyap: bool = false
var ending_c_state: String = ""

var played_timelines: Array[String] = []

var unlocked_endings: Array = []
const ENDINGS_FILE = "user://endings.cfg"

func has_played(timeline: String) -> bool:
	return played_timelines.has(timeline)

func mark_played(timeline: String) -> void:
	if not played_timelines.has(timeline):
		played_timelines.append(timeline)

func reset_game_state() -> void:
	current_day = 0
	can_sleep = false
	can_leave_room = false
	cafe_event_done = false
	is_night = false
	day4_state = ""
	alt2_post_bioskop = false
	alt2_epilog = false
	is_ending_c = false
	is_kubis_lenyap = false
	ending_c_state = ""
	played_timelines.clear()
	Dialogic.VAR.reset()
	
func save_game() -> void:
	var current_scene_path = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	if current_scene_path.contains("main_menu.tscn"):
		return # Jangan pernah nge-save saat di main menu
		
	var state = {
		"current_day": current_day,
		"can_sleep": can_sleep,
		"can_leave_room": can_leave_room,
		"cafe_event_done": cafe_event_done,
		"is_night": is_night,
		"day4_state": day4_state,
		"alt2_post_bioskop": alt2_post_bioskop,
		"alt2_epilog": alt2_epilog,
		"is_ending_c": is_ending_c,
		"is_kubis_lenyap": is_kubis_lenyap,
		"ending_c_state": ending_c_state,
		"played_timelines": played_timelines,
		"current_scene": current_scene_path
	}
	# Simpan ke slot spesifik, bukan global
	Dialogic.Save.save("auto_save", false, Dialogic.Save.ThumbnailMode.NONE, state)
	Dialogic.Save.set_slot_info("auto_save", state)
	print("[StoryManager] Game Auto-Saved!")
	_show_autosave_popup()

func _show_autosave_popup() -> void:
	if not get_tree().current_scene:
		return
		
	var canvas = CanvasLayer.new()
	canvas.layer = 150 # Di atas segalanya
	get_tree().current_scene.add_child(canvas)
	
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.5, 0.2, 0.9) # Hijau gelap semi-transparan
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	style.content_margin_left = 25
	style.content_margin_right = 25
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(panel)
	
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	
	var lbl = Label.new()
	lbl.text = "Game Ter-Save!"
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(lbl)
	
	# Animasi drop down lalu naik lagi
	panel.position.y = -80
	var tween = create_tween()
	tween.tween_property(panel, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(panel, "position:y", -80.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(canvas.queue_free)

func load_game() -> bool:
	if not Dialogic.Save.has_slot("auto_save"):
		return false
		
	Dialogic.Save.load("auto_save")
	var state = Dialogic.Save.get_slot_info("auto_save")
	if state == null or state.is_empty():
		return false
		
	current_day = state.get("current_day", 0)
	can_sleep = state.get("can_sleep", false)
	can_leave_room = state.get("can_leave_room", false)
	cafe_event_done = state.get("cafe_event_done", false)
	is_night = state.get("is_night", false)
	day4_state = state.get("day4_state", "")
	alt2_post_bioskop = state.get("alt2_post_bioskop", false)
	alt2_epilog = state.get("alt2_epilog", false)
	is_ending_c = state.get("is_ending_c", false)
	is_kubis_lenyap = state.get("is_kubis_lenyap", false)
	ending_c_state = state.get("ending_c_state", "")
	played_timelines = state.get("played_timelines", [])
	
	var scene_path = state.get("current_scene", "")
	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)
		
	print("[StoryManager] Game Loaded!")
	return true

func unlock_ending(ending_name: String) -> void:
	if not unlocked_endings.has(ending_name):
		unlocked_endings.append(ending_name)
		var config = ConfigFile.new()
		config.load(ENDINGS_FILE)
		config.set_value("History", "endings", unlocked_endings)
		config.save(ENDINGS_FILE)
		print("[StoryManager] Ending Unlocked: ", ending_name)

func _load_endings() -> void:
	var config = ConfigFile.new()
	if config.load(ENDINGS_FILE) == OK:
		unlocked_endings = config.get_value("History", "endings", [])

signal day_changed(new_day: int)

var transition_layer: CanvasLayer
var transition_rect: ColorRect
var transition_label: Label

func update_objective_based_on_state() -> void:
	if not has_node("/root/ObjectiveHUD"):
		return
	
	var obj = ""
	match current_day:
		0:
			if not is_night:
				obj = "Keluar kamar, ada telepon masuk!"
			else:
				if not can_sleep:
					obj = "Berbicara dengan Aloha (Iblis)"
				else:
					obj = "Tidur di kasur"
		1:
			if not is_night:
				if not cafe_event_done:
					obj = "Keluar kamar dan temui Mantan di Cafe"
				else:
					obj = "Waktunya pulang ke Kamar"
			else:
				if not can_sleep:
					obj = "Keluar kamar dan temui Mantan untuk meminjam DVD"
				else:
					obj = "Tidur di kasur"
		2:
			if not is_night:
				obj = "Minta rekomendasi film ke toko DVD"
			else:
				obj = "Tidur di kasur"
		3:
			if not is_night:
				obj = "Keluar kamar dan pergi ke Taman Bukit"
			else:
				obj = "Tidur di kasur"
		4:
			obj = "Cari Kubis! Ia pasti belum jauh!"
			# Hilangkan Kubis dari kamar pada Hari ke-4
			var choreo = get_tree().get_root().find_child("NPCChoreography", true, false)
			if choreo:
				choreo.queue_free()
				
			var kubis = get_tree().get_root().find_child("NPC_Kubis", true, false)
			if kubis:
				kubis.queue_free()
		100:
			if not can_leave_room:
				obj = "Bersiaplah, Mantan menunggumu di luar."
			else:
				obj = "Keluar dari kamar dan temui Mantan."
		101:
			if not can_leave_room:
				obj = "Lihat ke arah dapur (tempat mangkuk Kubis berada)."
			else:
				obj = "Keluar dari kamar dan jalani hari ini."
		99:
			return
			
	if has_node("/root/ObjectiveHUD"):
		get_node("/root/ObjectiveHUD").set_objective(obj)

func _ready() -> void:
	# Tunggu satu frame agar seluruh sistem terinisialisasi
	await get_tree().process_frame
	
	setup_transition_ui()
	_load_endings()
	
	if Dialogic.has_signal("timeline_started"):
		Dialogic.timeline_started.connect(_on_dialogue_started)
	if Dialogic.has_signal("timeline_ended"):
		Dialogic.timeline_ended.connect(_on_dialogue_ended)
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)

func setup_transition_ui() -> void:
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 100 # Pastikan selalu di atas
	add_child(transition_layer)
	
	transition_rect = ColorRect.new()
	transition_rect.color = Color(0, 0, 0, 1) # Hitam
	transition_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_rect.modulate = Color(1, 1, 1, 0) # Transparan di awal
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_layer.add_child(transition_rect)
	
	transition_label = Label.new()
	transition_label.text = "Hari ke-X"
	transition_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	transition_label.add_theme_font_size_override("font_size", 32)
	transition_rect.add_child(transition_label)
	
	transition_layer.visible = false

func _on_dialogic_signal(argument: String) -> void:
	print(">> STORY MANAGER MENERIMA SINYAL: ", argument)
	if argument == "ganti_hari":
		ganti_hari()
		save_game()
	elif argument == "event_selesai":
		print(">> Misi hari ini tamat! MC sekarang diizinkan tidur.")
		can_sleep = true
		Dialogic.VAR.set("event_harian_selesai", true)
		can_sleep = true
		print(">> Event harian selesai! MC sekarang bisa tidur.")
		update_objective_based_on_state()
	elif argument == "cafe_selesai":
		cafe_event_done = true
		print(">> Event cafe selesai. MC bisa masuk kamar lagi.")
		update_objective_based_on_state()
	if argument.begins_with("update_objective:"):
		var new_obj = argument.replace("update_objective:", "")
		if has_node("/root/ObjectiveHUD"):
			get_node("/root/ObjectiveHUD").set_objective(new_obj)
		return
	elif argument.begins_with("set_day4_state:"):
		day4_state = argument.replace("set_day4_state:", "")
		print(">> Day 4 state updated to: ", day4_state)
		return
		
	elif argument == "boleh_keluar":
		print(">> MC sekarang diizinkan keluar kamar.")
		can_leave_room = true
		if current_day == 1 and not is_night and not cafe_event_done:
			if has_node("/root/ObjectiveHUD"): get_node("/root/ObjectiveHUD").set_objective("Temui Mantan di Cafe (Jalanan Kota)")
		elif current_day == 4:
			if has_node("/root/ObjectiveHUD"): get_node("/root/ObjectiveHUD").set_objective("Cari Kubis di Parkiran!")
	elif argument == "teleport_ke_taman_bukit":
		print(">> Pindah otomatis ke Taman Bukit!")
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("unlock_movement"):
			player.unlock_movement()
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/Taman_Bukit.tscn", 1.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/Taman_Bukit.tscn")
		save_game()
	elif argument == "teleport_ke_taman":
		print(">> Pindah otomatis ke Taman!")
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("unlock_movement"):
			player.unlock_movement()
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/taman.tscn", 1.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/taman.tscn")
	elif argument == "teleport_ke_kamar_pagi":
		print(">> Pindah otomatis ke Kamar (Pagi)!")
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("unlock_movement"):
			player.unlock_movement()
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/kamar_mc.tscn", 0.5)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
	elif argument == "teleport_ke_pemakaman":
		print(">> Pindah otomatis ke Kantor Pemakaman!")
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("unlock_movement"):
			player.unlock_movement()
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/kantor_pemakaman.tscn", 0.5)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kantor_pemakaman.tscn")
	elif argument == "teleport_ke_bioskop_dari_taman":
		print(">> Pindah otomatis ke Bioskop!")
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("unlock_movement"):
			player.unlock_movement()
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/bioskop.tscn", 0.5)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/bioskop.tscn")
	elif argument == "tamat":
		print(">> GAME TAMAT!")
		unlock_ending("True Ending")
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/ui/credit_scene.tscn", 2.0) # Tamat lambat
		else:
			get_tree().change_scene_to_file("res://scenes/ui/credit_scene.tscn")
	elif argument == "day4_ke_kamar_beres2":
		print(">> Pindah otomatis ke Kamar untuk Beres-beres!")
		can_leave_room = false
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("unlock_movement"):
			player.unlock_movement()
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/kamar_mc.tscn", 0.5)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
		
		# Tunggu scene terganti dan fade in selesai
		await get_tree().create_timer(1.5).timeout
		
		# Pastikan dialog sebelumnya benar-benar tertutup
		if Dialogic.current_timeline != null:
			Dialogic.current_timeline = null
			
		var new_player = get_tree().get_first_node_in_group("Player")
		if new_player and new_player.has_method("lock_movement"):
			new_player.lock_movement()
			
		Dialogic.start("hari4_true_ending", "beres_beres")
	elif argument == "mantan_datang":
		# Cari NPC Mantan dan buat dia lari ke arah player
		var mantan = get_tree().get_root().find_child("NPC_Mantan", true, false)
		var player = get_tree().get_first_node_in_group("Player")
		if mantan and player:
			mantan.show()
			# Munculkan mantan agak jauh di atas pemain
			mantan.global_position = player.global_position + Vector2(0, -60)
			
			# Jalan ke arah pemain
			await mantan.walk_to_target(player.global_position + Vector2(0, -20), 1.5)
			
			# Mulai percakapan lanjutannya
			Dialogic.start("hari1_mantan_datang")
	elif argument == "mantan_ikut":
		var mantan = get_tree().get_root().find_child("NPC_Mantan", true, false)
		if mantan:
			mantan.is_following_player = true
			print(">> Mantan sekarang mengikuti Player!")

	elif argument == "aloha_datang":
		var aloha = get_tree().get_root().find_child("NPC_Aloha", true, false)
		var player = get_tree().get_first_node_in_group("Player")
		if aloha and player:
			aloha.show()
			
			var node_aloha = get_tree().get_root().find_child("PosisiAlohaHari3Malam", true, false)
			if StoryManager.current_day == 3 and node_aloha:
				aloha.global_position = node_aloha.global_position
			else:
				aloha.global_position = player.global_position + Vector2(30, 0)
			
			var tween = create_tween()
			aloha.modulate.a = 0
			tween.tween_property(aloha, "modulate:a", 1.0, 1.0)
	elif argument == "aloha_serius":
		var aloha = get_tree().get_root().find_child("NPC_Aloha", true, false)
		if aloha and aloha.has_node("AnimatedSprite2D"):
			aloha.get_node("AnimatedSprite2D").play("idle_down")
	elif argument == "aloha_hilang":
		var aloha = get_tree().get_root().find_child("NPC_Aloha", true, false)
		if aloha:
			var tween = create_tween()
			tween.tween_property(aloha, "modulate:a", 0.0, 1.0)
			await tween.finished
			aloha.hide()


	elif argument == "alt_malam_terakhir_selesai":
		current_day = 99 # Hari Alternatif A
		is_night = false
		can_sleep = false
		can_leave_room = false
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/kamar_mc.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
		# Tunggu lalu mainkan alt_pagi_terakhir
		await get_tree().create_timer(2.0).timeout
		while Dialogic.current_timeline != null:
			await get_tree().create_timer(0.1).timeout
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("lock_movement"): player.lock_movement()
		Dialogic.start("alt_pagi_terakhir")
	elif argument == "alt_pagi_terakhir_selesai":
		can_leave_room = true
		if has_node("/root/ObjectiveHUD"): get_node("/root/ObjectiveHUD").set_objective("Antar surat ke Kotak Pos di Jalanan Kota")
	elif argument == "alt_mengantar_surat_selesai":
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/Taman_Bukit.tscn", 1.5)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/Taman_Bukit.tscn")
	elif argument == "alt_taman_bukit_selesai":
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/kamar_mc.tscn", 1.5)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
		play_alt_sore_kamar()
	elif argument == "alt_tamat":
		print(">> GAME TAMAT ALT!")
		unlock_ending("Ending Damai")
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/ui/credit_damai.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/ui/credit_damai.tscn")
	elif argument == "alt2_start":
		current_day = 100 # Ending Bangkit
		is_night = false
		can_sleep = false
		can_leave_room = false
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/kamar_mc.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
	elif argument == "alt2_pagi_kamar_selesai":
		can_leave_room = true
		if has_node("/root/ObjectiveHUD"): get_node("/root/ObjectiveHUD").set_objective("Pergi ke Toko DVD (Tsutaya)")
	elif argument == "alt2_tsutaya_selesai":
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/jalan_malam_cutscene.tscn", 1.5)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/jalan_malam_cutscene.tscn")
	elif argument == "alt2_masuk_bioskop":
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/dalam_bioskop.tscn", 1.5)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/dalam_bioskop.tscn")
	elif argument == "alt2_bioskop_selesai":
		alt2_post_bioskop = true
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/jalan_malam_cutscene.tscn", 1.5)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/jalan_malam_cutscene.tscn")
	elif argument == "alt2_ending_bangkit_tamat":
		print(">> GAME TAMAT ALT 2!")
		unlock_ending("Ending Bangkit")
		alt2_epilog = true
		alt2_post_bioskop = false
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/kamar_mc.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
	elif argument == "ending_kesepian":
		is_ending_c = true
		is_kubis_lenyap = false # Akan hilang di dalam dialog kamar_awal
		Dialogic.start("ending_c_kamar_awal")
	elif argument == "fade_kubis":
		is_kubis_lenyap = true

		var choreo = get_tree().get_root().find_child("NPCChoreography", true, false)
		if choreo:
			choreo.queue_free()
		var kubis = get_tree().get_root().find_child("NPC_Kubis", true, false)
		if kubis:
			var tween = get_tree().create_tween()
			tween.tween_property(kubis, "modulate:a", 0.0, 1.5)
			await tween.finished
			kubis.queue_free()
	elif argument == "ending_c_lanjut_pagi":
		current_day = 101 # Day 101 is used for ending C
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/kamar_mc.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
	elif argument == "ending_c_ke_bioskop":
		ending_c_state = "luar_bioskop"
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/jalan_malam_cutscene.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/jalan_malam_cutscene.tscn")
	elif argument == "ending_c_masuk_bioskop":
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/dalam_bioskop.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/dalam_bioskop.tscn")
	elif argument == "ending_c_keluar_bioskop":
		ending_c_state = "luar_bioskop_post"
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/jalan_malam_cutscene.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/jalan_malam_cutscene.tscn")
	elif argument == "ending_c_pulang":
		ending_c_state = "epilog"
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/kamar_mc.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
	elif argument == "aloha_fade_in":
		var aloha = get_tree().get_root().find_child("NPC_Aloha", true, false)
		if aloha:
			aloha.show()
			aloha.modulate.a = 0.0
			var tween = get_tree().create_tween()
			tween.tween_property(aloha, "modulate:a", 1.0, 1.5)
	elif argument == "ending_c_credit":
		print(">> GAME TAMAT (ENDING KESEPIAN)!")
		unlock_ending("Ending Kesepian")
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/ui/credit_kesepian.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/ui/credit_kesepian.tscn")
	elif argument == "alt2_credit_bangkit_start":
		print(">> GAME TAMAT (ENDING BANGKIT)!")
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/ui/credit_bangkit.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/ui/credit_bangkit.tscn")

func _on_dialogue_started() -> void:
	if has_node("/root/ObjectiveHUD"):
		get_node("/root/ObjectiveHUD").hide_hud()
	
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("lock_movement"):
		player.lock_movement()

func _on_dialogue_ended() -> void:
	if has_node("/root/ObjectiveHUD"):
		get_node("/root/ObjectiveHUD").show_hud()
		
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("unlock_movement"):
		player.unlock_movement()

# Fungsi untuk memanggil pergantian hari dari kasur/interaksi tidur
func ganti_hari(target_scene: String = "") -> void:
	current_day += 1
	can_sleep = false
	can_leave_room = false
	
	# Sinkronkan dengan variabel Dialogic
	Dialogic.VAR.set("hari_ke", current_day)
	Dialogic.VAR.set("event_harian_selesai", false)
	is_night = false
	Dialogic.VAR.set("is_night", false)
	
	print("Sekarang adalah Hari ke-", current_day)
	
	# Transisi Layar Hitam (Fade In)
	transition_label.text = "Hari ke-" + str(current_day)
	transition_rect.modulate = Color(1, 1, 1, 0)
	transition_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	transition_layer.visible = true
	
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("lock_movement"):
		player.lock_movement()
		
	var tween_in = get_tree().create_tween()
	tween_in.tween_property(transition_rect, "modulate", Color(1, 1, 1, 1), 1.5)
	await tween_in.finished
	
	# Tahan Layar Hitam Selama 2 Detik agar tulisan mudah dibaca
	await get_tree().create_timer(2.0).timeout
	
	# Setup posisi MC saat layar sepenuhnya gelap
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
		await get_tree().process_frame
		await get_tree().process_frame

	day_changed.emit(current_day)
	
	player = get_tree().get_first_node_in_group("Player")
	if player:
		var node_tidur = get_tree().get_root().find_child("NodeMCEpilogTidur", true, false)
		if node_tidur:
			player.global_position = node_tidur.global_position
		else:
			player.global_position = Vector2(9, 25)
		
		if player.has_method("play_waking_up_animation"):
			# Fungsi ini akan secara asinkron memainkan animasi loncat ke samping kasur
			player.play_waking_up_animation()
	
	update_objective_based_on_state()
			
	# Fade Out: Kembali perlahan dari gelap, berbarengan dengan MC yang sedang melompat dari kasur
	var tween_out = get_tree().create_tween()
	tween_out.tween_property(transition_rect, "modulate", Color(1, 1, 1, 0), 1.5)
	await tween_out.finished
	
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_layer.visible = false
	
	if current_day == 4:
		if player and player.has_method("lock_movement"):
			player.lock_movement()
		Dialogic.start("hari4_true_ending")

func pulang_malam(target_scene: String) -> void:
	is_night = true
	Dialogic.VAR.set("is_night", true)
	
	transition_label.text = "" # Tidak ada teks hari ke-X
	transition_rect.modulate = Color(1, 1, 1, 0)
	transition_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	transition_layer.visible = true
	
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("lock_movement"):
		player.lock_movement()
		
	var tween_in = get_tree().create_tween()
	tween_in.tween_property(transition_rect, "modulate", Color(1, 1, 1, 1), 1.5)
	await tween_in.finished
	
	get_tree().change_scene_to_file(target_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	player = get_tree().get_first_node_in_group("Player")
	if player:
		if StoryManager.current_day == 3:
			var node_mc = get_tree().get_root().find_child("PosisiMCHari3Malam", true, false)
			if node_mc:
				player.global_position = node_mc.global_position
			else:
				player.global_position = Vector2(7, 29)
				
			var kubis = get_tree().get_root().find_child("NPC_Kubis", true, false)
			var node_kubis = get_tree().get_root().find_child("PosisiKubisHari3Malam", true, false)
			if kubis and node_kubis:
				kubis.global_position = node_kubis.global_position
		else:
			player.global_position = Vector2(7, 29) # Posisi di kamar dekat kasur
		
	var tween_out = get_tree().create_tween()
	tween_out.tween_property(transition_rect, "modulate", Color(1, 1, 1, 0), 1.5)
	await tween_out.finished
	
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_layer.visible = false
	
	save_game()
	
	# Langsung trigger dialog malam
	Dialogic.start("hari3_malam_kamar")


func play_alt_sore_kamar() -> void:
	await get_tree().create_timer(1.5).timeout
	while Dialogic.current_timeline != null:
		await get_tree().create_timer(0.1).timeout
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("lock_movement"):
		player.lock_movement()
	Dialogic.start("alt_sore_kamar")
