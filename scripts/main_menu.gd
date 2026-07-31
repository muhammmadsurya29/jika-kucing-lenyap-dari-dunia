extends Control

@onready var bg = $TextureRect
@onready var title_label = $Label
@onready var btn_mulai = $VBoxContainer/TombolMulai
@onready var btn_bgm = $VBoxContainer/TombolBGM
@onready var btn_keluar = $VBoxContainer/TombolKeluar

var pixel_font = preload("res://assets/font/ByteBounce.ttf")
var btn_mulai_base_text = "Mulai Game"
var btn_bgm_base_text = "BGM: ON"
var btn_keluar_base_text = "Keluar"

var is_bgm_muted = false

func _ready() -> void:
	Dialogic.end_timeline()
	
	var bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = preload("res://assets/audio/BGM_MAIN_MENU.mp3")
	bgm_player.bus = "Master"
	bgm_player.autoplay = true
	add_child(bgm_player)
	
	_setup_layout()
	_setup_pixel_theme()
	_start_animations()
	_setup_button_effects()
	_setup_gallery_ui()

var ending_slots: Array[VBoxContainer] = []
var texture_placeholder = preload("res://icon.svg") # Placeholder untuk image

func _setup_gallery_ui() -> void:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 60)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	# Jangkar di bagian bawah layar melebar
	hbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hbox.offset_top = -450  # Tarik lebih jauh ke atas (sebelumnya -350)
	hbox.offset_bottom = -250 # Beri jarak 250px dari tepi bawah (sebelumnya -150)
	add_child(hbox)
	
	# Ambil data ending yang sudah terbuka
	var sm = get_node_or_null("/root/StoryManager")
	var endings = sm.unlocked_endings if sm else []
	
	# Buat 4 slot foto
	for i in range(4):
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 10)
		
		var tex = TextureRect.new()
		tex.texture = texture_placeholder
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.custom_minimum_size = Vector2(240, 160) # Sedikit diperkecil agar tidak memakan layar
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		vbox.add_child(tex)
		
		var lbl = Label.new()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if pixel_font is FontFile:
			lbl.add_theme_font_override("font", pixel_font)
		lbl.add_theme_font_size_override("font_size", 24)
		
		if i < endings.size():
			lbl.text = str(endings[i])
			tex.modulate = Color(1, 1, 1, 1) # Terang
		else:
			lbl.text = "???"
			tex.modulate = Color(0.2, 0.2, 0.2, 1) # Gelap (Belum terbuka)
			
		vbox.add_child(lbl)
		hbox.add_child(vbox)
		ending_slots.append(vbox)

func _setup_layout():
	# Memaksa Judul agar rata tengah sempurna
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title_label.position.y = 200.0
	title_label.size.x = get_viewport_rect().size.x
	title_label.position.x = 0
	
	# Memaksa Tombol-tombol agar berada tepat di tengah layar
	var vbox = $VBoxContainer
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.position.x = (get_viewport_rect().size.x / 2.0) - (vbox.size.x / 2.0)
	vbox.position.y = 450.0 # Posisi Y untuk container tombol agar pas di tengah
	
	# Pusatkan teks di dalam tombol
	btn_mulai.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_bgm.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_keluar.alignment = HORIZONTAL_ALIGNMENT_CENTER

func _setup_pixel_theme():
	# Mematikan antialiasing pada font agar terlihat tajam (pixel-perfect)
	if pixel_font is FontFile:
		pixel_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		
	# Terapkan font ke judul (Lebih Besar & Bold)
	title_label.add_theme_font_override("font", pixel_font)
	title_label.add_theme_font_size_override("font_size", 100) # Diperbesar menjadi 100
	title_label.add_theme_constant_override("outline_size", 10) # Ditebalkan dengan outline
	title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	
	# Terapkan font ke tombol
	for btn in [btn_mulai, btn_bgm, btn_keluar]:
		btn.add_theme_font_override("font", pixel_font)
		btn.add_theme_font_size_override("font_size", 32)
		
		# Warna saat di-hover dan default
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color.YELLOW)
		btn.add_theme_color_override("font_focus_color", Color.YELLOW)
		
		# Hilangkan background kotak default agar terlihat seperti teks retro
		var empty_style = StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty_style)
		btn.add_theme_stylebox_override("hover", empty_style)
		btn.add_theme_stylebox_override("pressed", empty_style)
		btn.add_theme_stylebox_override("focus", empty_style)

func _start_animations():
	# 1. Efek "Bernapas" (Zoom In/Out pelan) untuk Background
	var bg_tween = create_tween().set_loops() # set_loops() membuat tween diulang terus menerus
	var base_scale = bg.scale
	var zoom_scale = base_scale * 1.05 # Membesar 5%
	
	bg_tween.tween_property(bg, "scale", zoom_scale, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bg_tween.tween_property(bg, "scale", base_scale, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Pusatkan origin agar zoom dari tengah
	bg.pivot_offset = bg.size / 2.0
	
	# 2. Efek Mengapung (Floating) untuk Judul
	var title_tween = create_tween().set_loops()
	var base_y = title_label.position.y
	title_tween.tween_property(title_label, "position:y", base_y - 15.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	title_tween.tween_property(title_label, "position:y", base_y, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _setup_button_effects():
	# Hubungkan sinyal hover
	btn_mulai.mouse_entered.connect(_on_btn_mulai_hover)
	btn_mulai.mouse_exited.connect(_on_btn_mulai_exit)
	
	btn_bgm.mouse_entered.connect(_on_btn_bgm_hover)
	btn_bgm.mouse_exited.connect(_on_btn_bgm_exit)
	btn_bgm.pressed.connect(_on_btn_bgm_pressed)
	
	btn_keluar.mouse_entered.connect(_on_btn_keluar_hover)
	btn_keluar.mouse_exited.connect(_on_btn_keluar_exit)
	
	# Pastikan pivot_offset di tengah agar efek membesar rapi
	btn_mulai.pivot_offset = btn_mulai.size / 2.0
	btn_bgm.pivot_offset = btn_bgm.size / 2.0
	btn_keluar.pivot_offset = btn_keluar.size / 2.0

func _on_btn_mulai_hover():
	btn_mulai.text = "> " + btn_mulai_base_text + " <"
	_tween_btn_scale(btn_mulai, 1.2)

func _on_btn_mulai_exit():
	btn_mulai.text = btn_mulai_base_text
	_tween_btn_scale(btn_mulai, 1.0)

func _on_btn_bgm_hover():
	btn_bgm.text = "> " + btn_bgm_base_text + " <"
	_tween_btn_scale(btn_bgm, 1.2)

func _on_btn_bgm_exit():
	btn_bgm.text = btn_bgm_base_text
	_tween_btn_scale(btn_bgm, 1.0)

func _on_btn_bgm_pressed():
	is_bgm_muted = !is_bgm_muted
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_index, is_bgm_muted)
	
	if is_bgm_muted:
		btn_bgm_base_text = "BGM: OFF"
	else:
		btn_bgm_base_text = "BGM: ON"
		
	btn_bgm.text = "> " + btn_bgm_base_text + " <"

func _on_btn_keluar_hover():
	btn_keluar.text = "> " + btn_keluar_base_text + " <"
	_tween_btn_scale(btn_keluar, 1.2)

func _on_btn_keluar_exit():
	btn_keluar.text = btn_keluar_base_text
	_tween_btn_scale(btn_keluar, 1.0)

func _tween_btn_scale(btn: Button, target_scale: float):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(target_scale, target_scale), 0.1)

func _on_tombol_mulai_pressed() -> void:
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.reset_game_state()
	get_tree().change_scene_to_file("res://scenes/maps/prolog.tscn")

func _on_tombol_keluar_pressed() -> void:
	get_tree().quit()
