extends Node2D

@onready var tsutaya = $NPC_Tsutaya
@onready var player = $Player

func _ready() -> void:
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	# Pastikan pintu keluar terkunci di awal
	var pintu = get_node_or_null("PintuKeluar")
	if pintu:
		pintu.requires_leave_permission = true
		
	if StoryManager.current_day == 100:
		_play_alt2_tsutaya()
	elif StoryManager.current_day == 2:
		# Auto trigger dialog Day 2 setelah masuk toko DVD
		if not Dialogic.current_timeline:
			var sm = get_node_or_null("/root/StoryManager")
			if sm and not sm.has_played("hari2_siang_tsutaya"):
				sm.mark_played("hari2_siang_tsutaya")
				Dialogic.start("hari2_siang_tsutaya")

func _play_alt2_tsutaya() -> void:
	await get_tree().create_timer(1.0).timeout
	if player and player.has_method("lock_movement"):
		player.lock_movement()
	Dialogic.start("alt2_tsutaya")

func _on_dialogic_signal(argument: String) -> void:
	if argument == "tsutaya_cari_dvd":
		_tsutaya_cari_dvd()
	elif argument == "tsutaya_kembali":
		_tsutaya_kembali()

func _tsutaya_cari_dvd() -> void:
	if not tsutaya: return
	
	var anim = tsutaya.get_node_or_null("AnimatedSprite2D")
	var tween = create_tween()
	var start_pos = tsutaya.global_position
	
	# Jalan ke kiri
	if anim: tween.tween_callback(anim.play.bind("walk_left"))
	tween.tween_property(tsutaya, "global_position:x", start_pos.x - 40, 1.0)
	
	# Berhenti dan cek rak (idle_up)
	if anim: tween.tween_callback(anim.play.bind("idle_up"))
	tween.tween_interval(1.5) # diam cek rak selama 1.5 detik
	
	# Jalan ke kanan
	if anim: tween.tween_callback(anim.play.bind("walk_right"))
	tween.tween_property(tsutaya, "global_position:x", start_pos.x + 80, 2.0) # Bergerak lewati start_pos
	
	# Berhenti dan cek rak lagi
	if anim: tween.tween_callback(anim.play.bind("idle_up"))
	tween.tween_interval(1.5)
	
	# Standby menghadap player (idle_left)
	if anim: tween.tween_callback(anim.play.bind("idle_left"))

func _tsutaya_kembali() -> void:
	if not tsutaya: return
	
	# Jeda dialogic: The user put [signal arg="tsutaya_kembali"] BEFORE tsutaya speaks. 
	Dialogic.paused = true
	
	var anim = tsutaya.get_node_or_null("AnimatedSprite2D")
	var tween = create_tween()
	
	# Asumsi MC ada di kiri bawah, Tsutaya jalan kembali
	if anim: tween.tween_callback(anim.play.bind("walk_left"))
	# Kembali ke dekat player (kiri/kanan)
	tween.tween_property(tsutaya, "global_position", player.global_position + Vector2(20, -10), 1.5)
	
	# Sesudah sampai, menghadap MC (kiri)
	if anim: tween.tween_callback(anim.play.bind("idle_left"))
	
	await tween.finished
	
	Dialogic.paused = false
