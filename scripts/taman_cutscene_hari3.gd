extends Node2D

@onready var kubis = $NPC_Kubis
var player: Node2D

# Referensi NPC yang di-instantiate di hari 99
var npc_anak: Node2D = null
var npc_ibu: Node2D = null

func _ready() -> void:
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	player = get_tree().get_first_node_in_group("Player")
	
	if StoryManager.current_day == 3:
		# Sembunyikan trigger taman default untuk mencegah tabrakan timeline
		var trigger_taman = get_node_or_null("TriggerTaman")
		if trigger_taman:
			trigger_taman.queue_free()
		
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.monitoring = false
			if not trigger_bangku.body_entered.is_connected(_on_trigger_bangku_body_entered):
				trigger_bangku.body_entered.connect(_on_trigger_bangku_body_entered)
				
		var trigger_bunga = get_node_or_null("TriggerBunga")
		if trigger_bunga:
			trigger_bunga.monitoring = true
			if not trigger_bunga.body_entered.is_connected(_on_trigger_bunga_body_entered):
				trigger_bunga.body_entered.connect(_on_trigger_bunga_body_entered)
		
		# Langsung jalankan animasi kubis ke arah bunga tanpa mengunci player
		_jalan_ke_kanan_anim()

	elif StoryManager.current_day == 99:
		# Setup Sinematik Hari 99
		# Kunci pergerakan langsung agar animasi tidak ditimpa oleh _physics_process
		if player and player.has_method("lock_movement"):
			player.lock_movement()
			
		var node_mc = get_node_or_null("NodeA_MC")
		if player and node_mc:
			player.global_position = node_mc.global_position
			if player.has_method("play_custom_animation"):
				player.play_custom_animation("sit_left")
		
		# Untuk Kubis
		# Jika kubis tidak ada (queue_free sebelumnya), maka kita perlu instansiasi jika perlu, 
		# Tapi di script ini kubis = $NPC_Kubis yang ada di scene sejak awal.
		if not kubis:
			var kubis_scene = load("res://scenes/characters/cat.tscn")
			if kubis_scene:
				kubis = kubis_scene.instantiate()
				add_child(kubis)
				
		var node_kubis = get_node_or_null("NodeB_Kubis")
		if kubis and node_kubis:
			kubis.global_position = node_kubis.global_position
			var anim = kubis.get_node_or_null("AnimatedSprite2D")
			if anim:
				anim.play("sit_down")
				
		# Sembunyikan trigger agar tidak ada interaksi manual
		var trigger_taman = get_node_or_null("TriggerTaman")
		if trigger_taman: trigger_taman.queue_free()
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku: trigger_bangku.queue_free()
		
		# Mainkan dialog otomatis setelah scene dimuat
		_play_alt_taman_bukit()

	else:
		# Jika bukan hari ke-3 atau 99, hapus trigger bangku khusus dan kubis
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.queue_free()
			
		if kubis:
			kubis.queue_free()

func _on_dialogic_signal(argument: String) -> void:
	if argument == "kubis_jalan_ke_bunga":
		_jalan_ke_kanan_anim()
	elif argument == "kubis_jalan_ke_bukit":
		_jalan_ke_atas_anim()
	elif argument == "aktifkan_bangku":
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.set_deferred("monitoring", true)
	elif argument == "aktifkan_bunga":
		var trigger_bunga = get_node_or_null("TriggerBunga")
		if trigger_bunga:
			trigger_bunga.set_deferred("monitoring", true)
	elif argument == "ganti_hari_langsung":
		var sm = get_node_or_null("/root/StoryManager")
		if sm:
			if sm.has_method("pulang_malam"):
				sm.pulang_malam("res://scenes/maps/kamar_mc.tscn")
			else:
				sm.ganti_hari("res://scenes/maps/kamar_mc.tscn")
	elif argument == "anak_muncul":
		_munculkan_anak()
	elif argument == "ibu_muncul":
		_munculkan_ibu()

func _munculkan_anak() -> void:
	var anak_scene = load("res://scenes/characters/kencur.tscn")
	if not anak_scene: return
	npc_anak = anak_scene.instantiate()
	add_child(npc_anak)
	
	var spawn = get_node_or_null("NodeSpawnAnak")
	var target = get_node_or_null("NodeTitikAnak")
	
	if spawn and target:
		npc_anak.global_position = spawn.global_position
		var anim = npc_anak.get_node_or_null("AnimatedSprite2D")
		if anim: anim.play("walk_down")
		
		var dist = spawn.global_position.distance_to(target.global_position)
		var time = dist / 60.0
		var tween = create_tween()
		tween.tween_property(npc_anak, "global_position", target.global_position, time)
		await tween.finished
		
		if anim: anim.play("idle_down")
		
	# Lanjutkan dialog
	Dialogic.VAR.set("anak_sampai", true)

func _munculkan_ibu() -> void:
	var ibu_scene = load("res://scenes/characters/ibu_kencur.tscn")
	if not ibu_scene: return
	npc_ibu = ibu_scene.instantiate()
	add_child(npc_ibu)
	
	var spawn = get_node_or_null("NodeSpawnIbu")
	var target = get_node_or_null("NodeTitikIbu")
	
	if spawn and target:
		npc_ibu.global_position = spawn.global_position
		var anim = npc_ibu.get_node_or_null("AnimatedSprite2D")
		if anim: anim.play("walk_down")
		
		var dist = spawn.global_position.distance_to(target.global_position)
		var time = dist / 60.0
		var tween = create_tween()
		tween.tween_property(npc_ibu, "global_position", target.global_position, time)
		await tween.finished
		
		if anim: anim.play("idle_down")
		
	# Lanjutkan dialog
	Dialogic.VAR.set("ibu_sampai", true)

func _jalan_ke_kanan_anim() -> void:
	if kubis:
		var anim = kubis.get_node_or_null("AnimatedSprite2D")
		if anim:
			anim.play("walk_down")
		
		var tween = create_tween()
		var target = get_node_or_null("NodeBungaRandaTapak")
		if target:
			tween.tween_property(kubis, "global_position", target.global_position, 5.0)
		else:
			tween.tween_property(kubis, "position:y", kubis.position.y + 80, 5.0)
		await tween.finished
		
		if anim:
			anim.play("idle_down")

func _jalan_ke_atas_anim() -> void:
	if kubis:
		var anim = kubis.get_node_or_null("AnimatedSprite2D")
		if anim:
			anim.play("walk_down")
		
		var tween = create_tween()
		var target = get_node_or_null("NodeBangkuKakek")
		if target:
			tween.tween_property(kubis, "global_position", target.global_position, 6.0)
		else:
			tween.tween_property(kubis, "position:y", kubis.position.y + 100, 6.0)
		await tween.finished
		
		if anim:
			anim.play("idle_down")

# Script dipanggil oleh Area2D bunga
func _on_trigger_bunga_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and StoryManager.current_day == 3:
		var trigger_bunga = get_node_or_null("TriggerBunga")
		if trigger_bunga:
			trigger_bunga.set_deferred("monitoring", false)
			
		if player and player.has_method("lock_movement"):
			player.lock_movement()
			
		if not Dialogic.current_timeline:
			Dialogic.start("hari3_taman_bagian1")

# Script dipanggil oleh Area2D bangku
func _on_trigger_bangku_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and StoryManager.current_day == 3:
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.set_deferred("monitoring", false)
			
		if player and player.has_method("lock_movement"):
			player.lock_movement()
			
		if player and player.has_method("play_custom_animation"):
			player.play_custom_animation("sit_left")
			
		if not Dialogic.current_timeline:
			Dialogic.start("hari3_taman_bagian2")

func _play_alt_taman_bukit() -> void:
	await get_tree().create_timer(1.0).timeout
	while Dialogic.current_timeline != null:
		await get_tree().create_timer(0.1).timeout
	if player and player.has_method("lock_movement"):
		player.lock_movement()
	Dialogic.start("alt_taman_bukit")
