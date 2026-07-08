extends Node2D

@onready var parallax_bg = $ParallaxBackground
@onready var bioskop = $GedungBioskop
@onready var player = $Player
@onready var mantan = $NPC_Mantan
@onready var aloha = $NPC_Aloha

var is_walking = false
var walk_speed = 50.0
var target_x = 0.0

func _ready() -> void:
	# Dengarkan sinyal dari Dialogic
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	# Sembunyikan ParallaxBackground jika ada
	if parallax_bg:
		parallax_bg.hide()
		
	# Setup posisi Gedung Bioskop
	bioskop.position.x = 800.0 # Posisi jauh di kanan
	
	# Buat marker tujuan di depan pintu bioskop secara dinamis
	var pintu = Marker2D.new()
	pintu.name = "NodeDepanPintuBioskop"
	pintu.position = Vector2(-20, 50) # 20px di sebelah kiri dan 50px ke bawah dari pusat gedung
	bioskop.add_child(pintu)
	target_x = bioskop.position.x + pintu.position.x
	
	# Pindahkan kamera ke Player agar mengikuti (jika belum)
	var camera = $Camera2D
	if camera:
		remove_child(camera)
		player.add_child(camera)
		camera.position = Vector2(0, 0)
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 5.0
		
	# Setup awal karakter
	aloha.hide()
	aloha.modulate.a = 0.0
	player.position.x = 80.0
	mantan.position.x = 40.0 # Mantan berjalan di belakang MC
	
	# Mulai cutscene
	start_walking()

func start_walking():
	is_walking = true
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("walk_right")
		if player.has_node("AnimatedSprite2D"):
			player.get_node("AnimatedSprite2D").speed_scale = 0.5
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("walk_right")
		mantan.get_node("AnimatedSprite2D").speed_scale = 0.5
		
	# Matikan AI follower jika ada
	if "is_following_player" in mantan:
		mantan.is_following_player = false
		mantan.is_moving = false
		
	# Mulai dialog
	if not Dialogic.current_timeline:
		Dialogic.start("hari1_malam_jalan")

func _process(delta: float) -> void:
	if is_walking:
		# Karakter benar-benar berjalan menyusuri koordinat X
		player.position.x += walk_speed * delta
		mantan.position.x += walk_speed * delta
		
		# Jika MC sudah mencapai target di depan pintu bioskop
		if player.position.x >= target_x:
			is_walking = false
			_karakter_berhenti()

func _on_dialogic_signal(argument: String) -> void:
	if argument == "mantan_pergi":
		_mantan_masuk_bioskop()
	elif argument == "aloha_muncul":
		_munculkan_aloha()
	elif argument == "mc_pingsan":
		_mc_pingsan()

func _karakter_berhenti():
	# Kembalikan kecepatan animasi normal
	if player.has_node("AnimatedSprite2D"):
		player.get_node("AnimatedSprite2D").speed_scale = 1.0
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").speed_scale = 1.0
		
	# Setelah sampai, karakter berhenti dan menghadap ke atas (ke arah pintu gedung)
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("idle_up")
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("idle_up")
		
func _mantan_masuk_bioskop():
	# Mantan berjalan ke atas (masuk pintu)
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("walk_up")
		
	var tween = create_tween()
	tween.tween_property(mantan, "position:y", mantan.position.y - 40, 1.5)
	await tween.finished
	
	# Mantan menghilang setelah masuk
	mantan.hide()
	
func _munculkan_aloha():
	# Posisikan Aloha agak ke kiri dari MC
	aloha.position.x = player.position.x - 50.0
	aloha.position.y = player.position.y
	
	# Aloha muncul (fade in)
	aloha.show()
	if aloha.has_node("AnimatedSprite2D"):
		aloha.get_node("AnimatedSprite2D").play("idle_right") # Aloha menghadap MC
		
	var tween = create_tween()
	tween.tween_property(aloha, "modulate:a", 1.0, 1.0)
	
	# MC menghadap ke Aloha (ke arah kiri)
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("idle_left")

func _mc_pingsan():
	# Matikan timeline agar tidak menggantung
	if Dialogic.current_timeline:
		Dialogic.end_timeline()
		
	# Animasi pingsan darurat: Rotasi 90 derajat
	var tween = create_tween()
	tween.tween_property(player, "rotation_degrees", 90.0, 0.5)
	tween.tween_property(player, "position:y", player.position.y + 10, 0.5)
	await tween.finished
	
	# Ganti ke hari ke-2
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.current_day = 1
		sm.ganti_hari("res://scenes/maps/kamar_mc.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
