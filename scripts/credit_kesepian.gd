extends Control

@onready var quote_label = $QuoteText
@onready var ending_label = $EndingText
@onready var credit_container = $CreditContainer

var scroll_speed: float = 35.0
var scrolling: bool = false

func _ready() -> void:
	quote_label.text = "Kita sering berpikir bahwa kehilangan adalah sesuatu yang datang dari luar takdir, penyakit, waktu. Tapi ada kehilangan yang kita pilih sendiri. Karena kita terlalu takut untuk melepaskan dengan cara yang benar. Karena kita mengira menghilangkan lebih mudah daripada mengikhlaskan.\nPadahal tidak. Mengikhlaskan meninggalkan kenangan. Menghilangkan hanya meninggalkan kekosongan.\nDan kekosongan itu tidak pernah pergi."
	ending_label.text = "ENDING KESEPIAN"
	
	quote_label.modulate.a = 0
	ending_label.modulate.a = 0
	credit_container.modulate.a = 0
	
	var viewport_size = get_viewport_rect().size
	credit_container.position.y = viewport_size.y + 50
	
	# Load and play audio dynamically to avoid resource path issues
	var audio = AudioStreamPlayer.new()
	var stream = load("res://assets/audio/wave_love.mp3")
	if stream:
		audio.stream = stream
		audio.name = "BGMPlayer"
		add_child(audio)
		audio.play()
	
	_play_sequence()

func _play_sequence() -> void:
	# 1. Fade in quote
	var tween = create_tween()
	tween.tween_property(quote_label, "modulate:a", 1.0, 2.0)
	tween.tween_interval(6.0)
	tween.tween_property(quote_label, "modulate:a", 0.0, 2.0)
	await tween.finished
	
	# 2. Fade in ENDING DAMAI
	var tween2 = create_tween()
	tween2.tween_property(ending_label, "modulate:a", 1.0, 2.0)
	tween2.tween_interval(3.0)
	tween2.tween_property(ending_label, "modulate:a", 0.0, 2.0)
	await tween2.finished
	
	# 3. Tampilkan Credit Text
	credit_container.modulate.a = 1.0
	scrolling = true

func _process(delta: float) -> void:
	if scrolling:
		credit_container.position.y -= scroll_speed * delta
		
		if credit_container.position.y + credit_container.size.y < -50:
			scrolling = false
			_end_credits()

func _end_credits() -> void:
	var bgm = get_node_or_null("BGMPlayer")
	if bgm:
		var tween = create_tween()
		tween.tween_property(bgm, "volume_db", -40.0, 2.0)
		await tween.finished
	
	var bgm_manager = get_node_or_null("/root/BGMManager")
	if bgm_manager:
		bgm_manager.play_track("main_menu")
		
	if has_node("/root/ScreenFade"):
		get_node("/root/ScreenFade").transition_to("res://scenes/ui/main_menu.tscn", 1.0)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
