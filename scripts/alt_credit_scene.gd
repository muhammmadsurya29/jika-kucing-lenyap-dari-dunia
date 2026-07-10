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
	# 1. Set teks ke quote panjang
	true_ending_label.text = "\"Apakah hidup lebih lama selalu lebih baik?\nMungkin bukan soal panjangnya. Mungkin soal apakah di akhirnya kita bisa duduk tenang dan berkata: ya, ini hidupku. Dan aku tidak menukarnya dengan apapun.\""
	true_ending_label.add_theme_font_size_override("font_size", 24)
	true_ending_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	true_ending_label.custom_minimum_size = Vector2(800, 0)
	
	# Fade in quote
	var tween = create_tween()
	tween.tween_property(true_ending_label, "modulate:a", 1.0, 2.0)
	tween.tween_interval(6.0)
	tween.tween_property(true_ending_label, "modulate:a", 0.0, 2.0)
	await tween.finished
	
	# 2. Set teks ke ENDING DAMAI
	true_ending_label.text = "— TAMAT / ENDING DAMAI —"
	true_ending_label.add_theme_font_size_override("font_size", 48)
	
	var tween2 = create_tween()
	tween2.tween_property(true_ending_label, "modulate:a", 1.0, 2.0)
	tween2.tween_interval(3.0)
	tween2.tween_property(true_ending_label, "modulate:a", 0.0, 2.0)
	await tween2.finished
	
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
	tween.tween_property(bgm_player, "volume_db", -40.0, 2.0)
	await tween.finished
	
	if has_node("/root/ScreenFade"):
		get_node("/root/ScreenFade").transition_to("res://scenes/ui/main_menu.tscn", 1.0)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
