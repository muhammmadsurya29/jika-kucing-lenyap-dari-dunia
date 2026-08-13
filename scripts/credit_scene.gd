extends Control

@onready var true_ending_label = $TrueEndingText
@onready var credit_container = $CreditContainer
@onready var bgm_player = $BGMPlayer

var scroll_speed: float = 35.0
var scrolling: bool = false

func _ready() -> void:
	# Sembunyikan dan set awal
	true_ending_label.modulate.a = 0
	credit_container.modulate.a = 0
	
	# Posisikan Credit Container di bawah layar
	var viewport_size = get_viewport_rect().size
	credit_container.position.y = viewport_size.y + 50
	
	# Mainkan BGM
	if bgm_player.stream:
		bgm_player.play()
	
	# Mulai sequence
	_play_sequence()

func _play_sequence() -> void:
	# 1. Fade in tulisan True Ending
	var tween = create_tween()
	tween.tween_property(true_ending_label, "modulate:a", 1.0, 2.0)
	
	# 2. Tahan selama 3 detik
	tween.tween_interval(3.0)
	
	# 3. Fade out tulisan True Ending
	tween.tween_property(true_ending_label, "modulate:a", 0.0, 2.0)
	
	# Tunggu tween selesai sebelum lanjut
	await tween.finished
	
	# 4. Tampilkan Credit Text
	credit_container.modulate.a = 1.0
	scrolling = true

func _process(delta: float) -> void:
	if scrolling:
		credit_container.position.y -= scroll_speed * delta
		
		# Jika seluruh credit sudah melewati batas atas layar
		if credit_container.position.y + credit_container.size.y < -50:
			scrolling = false
			_end_credits()

func _end_credits() -> void:
	var tween = create_tween()
	# Optional: fade out musik pelan-pelan
	tween.tween_property(bgm_player, "volume_db", -40.0, 2.0)
	await tween.finished
	
	# Kembali ke Main Menu
	var bgm_manager = get_node_or_null("/root/BGMManager")
	if bgm_manager:
		bgm_manager.play_track("main_menu")
		
	if has_node("/root/ScreenFade"):
		get_node("/root/ScreenFade").transition_to("res://scenes/ui/main_menu.tscn", 1.0)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
