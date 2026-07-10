extends Node2D

@onready var parallax_bg = $ParallaxBackground
@onready var bioskop = $GedungBioskop
@onready var player = $Player
@onready var mantan = $NPC_Mantan
@onready var aloha = $NPC_Aloha

var is_walking = false
var walk_speed = 15.0 # Sangat lambat
var target_x = 0.0

func _ready() -> void:
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	if parallax_bg:
		parallax_bg.hide()
		
	var pintu = bioskop.get_node_or_null("NodeDepanPintuBioskop")
	if pintu:
		target_x = bioskop.position.x + pintu.position.x
	else:
		target_x = bioskop.position.x - 20.0
		
	aloha.hide()
	aloha.modulate.a = 0.0
	
	if StoryManager.current_day == 100:
		_setup_day100()
	else:
		_setup_normal()

func _setup_normal():
	var titik_mulai = get_node_or_null("NodeTitikMulai")
	if titik_mulai:
		player.position = titik_mulai.position
		mantan.position = titik_mulai.position - Vector2(40, 0)
	else:
		player.position.x = 80.0
		mantan.position.x = 40.0
	start_walking()

func _setup_day100():
	is_walking = false
	var node_mc = get_node_or_null("NodeMCDuduk")
	if node_mc:
		player.position = node_mc.position
	else:
		player.position.x = target_x - 10
		player.position.y = bioskop.position.y + 40
		
	var node_mantan = get_node_or_null("NodeMantanMulai")
	if node_mantan:
		mantan.position = node_mantan.position
	else:
		mantan.position.x = target_x - 200
		mantan.position.y = player.position.y
		
	if "is_following_player" in mantan:
		mantan.is_following_player = false
		mantan.is_moving = false
		
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("sit_down")
	elif player.has_node("AnimatedSprite2D"):
		player.get_node("AnimatedSprite2D").play("sit_down")
		
	if not Dialogic.current_timeline:
		Dialogic.start("alt2_luar_bioskop")

func start_walking():
	is_walking = true
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("walk_right")
		if player.has_node("AnimatedSprite2D"):
			player.get_node("AnimatedSprite2D").speed_scale = 0.25
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("walk_right")
		mantan.get_node("AnimatedSprite2D").speed_scale = 0.25
		
	if "is_following_player" in mantan:
		mantan.is_following_player = false
		mantan.is_moving = false
		
	if not Dialogic.current_timeline:
		Dialogic.start("hari1_malam_jalan")

func _process(delta: float) -> void:
	if is_walking:
		player.position.x += walk_speed * delta
		mantan.position.x += walk_speed * delta
		
		if player.position.x >= target_x:
			is_walking = false
			_karakter_berhenti()

func _on_dialogic_signal(argument: String) -> void:
	if argument == "sampai_bioskop":
		if is_walking:
			Dialogic.paused = true
	elif argument == "mantan_pergi":
		_mantan_masuk_bioskop()
	elif argument == "aloha_muncul":
		_munculkan_aloha()
	elif argument == "mc_pingsan":
		_mc_pingsan()
	elif argument == "alt2_mantan_datang_awal":
		_alt2_mantan_datang()
	elif argument == "alt2_mantan_duduk":
		_alt2_mantan_duduk()

func _alt2_mantan_datang():
	Dialogic.paused = true
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("walk_right")
		
	var target_pos = player.position.x - 30
	var node_duduk = get_node_or_null("NodeMantanDuduk")
	if node_duduk:
		target_pos = node_duduk.position.x
		
	var tween = create_tween()
	tween.tween_property(mantan, "position:x", target_pos, 2.5)
	await tween.finished
	
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("idle_right")
	Dialogic.paused = false

func _alt2_mantan_duduk():
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("sit_right")

func _karakter_berhenti():
	if player.has_node("AnimatedSprite2D"):
		player.get_node("AnimatedSprite2D").speed_scale = 1.0
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").speed_scale = 1.0
		
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("idle_up")
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("idle_up")
		
	if Dialogic.paused:
		Dialogic.paused = false
		
func _mantan_masuk_bioskop():
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("walk_up")
		
	var tween = create_tween()
	tween.tween_property(mantan, "position:y", mantan.position.y - 40, 1.5)
	await tween.finished
	mantan.hide()
	
func _munculkan_aloha():
	aloha.position.x = player.position.x - 50.0
	aloha.position.y = player.position.y
	aloha.show()
	if aloha.has_node("AnimatedSprite2D"):
		aloha.get_node("AnimatedSprite2D").play("idle_right")
		
	var tween = create_tween()
	tween.tween_property(aloha, "modulate:a", 1.0, 1.0)
	
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("idle_left")

func _mc_pingsan():
	if Dialogic.current_timeline:
		Dialogic.end_timeline()
		
	var tween = create_tween()
	tween.tween_property(player, "rotation_degrees", 90.0, 0.5)
	tween.tween_property(player, "position:y", player.position.y + 10, 0.5)
	await tween.finished
	
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.current_day = 1
		sm.ganti_hari("res://scenes/maps/kamar_mc.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
