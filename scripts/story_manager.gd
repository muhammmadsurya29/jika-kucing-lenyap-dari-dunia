extends Node

# Script Global (Autoload) untuk manajemen alur cerita dan state game

var current_day: int = 0
var can_sleep: bool = false
var can_leave_room: bool = false
var cafe_event_done: bool = false
var is_night: bool = false

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
	
	if has_node("/root/ObjectiveHUD"):
		get_node("/root/ObjectiveHUD").set_objective(obj)

func _ready() -> void:
	# Tunggu satu frame agar seluruh sistem terinisialisasi
	await get_tree().process_frame
	
	setup_transition_ui()
	
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
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/prolog.tscn", 2.0) # Tamat lambat
		else:
			get_tree().change_scene_to_file("res://scenes/maps/prolog.tscn")
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

func _on_dialogue_started() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("lock_movement"):
		player.lock_movement()

func _on_dialogue_ended() -> void:
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
		player.global_position = Vector2(7, 29)
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
	
	# Langsung trigger dialog malam
	Dialogic.start("hari3_malam_kamar")
