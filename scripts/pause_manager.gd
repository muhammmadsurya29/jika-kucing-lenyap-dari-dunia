extends CanvasLayer

var btn_pause: Button
var panel_overlay: PanelContainer
var is_menu = true

@export var pause_bg_color: Color = Color(0.014, 0.014, 0.014, 0.8)
@export var pause_icon: Texture2D
@export var pause_text: String = " || Pause "

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 120
	
	btn_pause = Button.new()
	btn_pause.text = pause_text
	
	btn_pause.add_theme_font_size_override("font_size", 20)
	btn_pause.add_theme_color_override("font_color", Color.BLACK)
	btn_pause.add_theme_color_override("font_hover_color", Color.BLACK)
	btn_pause.add_theme_color_override("font_focus_color", Color.BLACK)
	btn_pause.add_theme_color_override("font_pressed_color", Color.BLACK)
	
	btn_pause.set_anchors_preset(Control.PRESET_TOP_LEFT)
	btn_pause.position = Vector2(20, 20)
	btn_pause.pressed.connect(_on_pause_pressed)
	
	var style = StyleBoxTexture.new()
	style.texture = preload("res://assets/ui/Pause.png")
	style.texture_margin_left = 15
	style.texture_margin_right = 15
	style.texture_margin_top = 8
	style.texture_margin_bottom = 8
	
	var style_hover = style.duplicate()
	style_hover.modulate_color = Color(1.2, 1.2, 1.2, 1.0)
	
	btn_pause.add_theme_stylebox_override("normal", style)
	btn_pause.add_theme_stylebox_override("hover", style_hover)
	btn_pause.add_theme_stylebox_override("pressed", style_hover)
	btn_pause.add_theme_stylebox_override("focus", style_hover)
	
	add_child(btn_pause)
	
	_build_overlay()
	hide_ui()

func _process(delta: float) -> void:
	if get_tree().current_scene:
		var scene_path = get_tree().current_scene.scene_file_path
		if scene_path.contains("main_menu") or scene_path.contains("prolog") or scene_path.contains("credit"):
			if not is_menu:
				is_menu = true
				hide_ui()
		else:
			if is_menu:
				is_menu = false
				btn_pause.show()

func hide_ui():
	btn_pause.hide()
	panel_overlay.hide()
	get_tree().paused = false

func _build_overlay():
	panel_overlay = PanelContainer.new()
	panel_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.8)
	panel_overlay.add_theme_stylebox_override("panel", style)
	add_child(panel_overlay)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	panel_overlay.add_child(vbox)
	
	var lbl = Label.new()
	lbl.text = "GAME PAUSED"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 40)
	vbox.add_child(lbl)
	
	var btn_lanjut = Button.new()
	btn_lanjut.text = "Lanjutkan Game"
	btn_lanjut.custom_minimum_size = Vector2(250, 60)
	btn_lanjut.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_lanjut.pressed.connect(_on_lanjut_pressed)
	vbox.add_child(btn_lanjut)
	
	var btn_keluar = Button.new()
	btn_keluar.text = "Keluar ke Menu"
	btn_keluar.custom_minimum_size = Vector2(250, 60)
	btn_keluar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_keluar.pressed.connect(_on_keluar_pressed)
	vbox.add_child(btn_keluar)

func _on_pause_pressed():
	if get_tree().paused:
		_on_lanjut_pressed()
	else:
		get_tree().paused = true
		panel_overlay.show()

func _on_lanjut_pressed():
	get_tree().paused = false
	panel_overlay.hide()

func _on_keluar_pressed():
	get_tree().paused = false
	panel_overlay.hide()
	is_menu = true
	btn_pause.hide()
	
	# Simpan state permainan ke file sebelum keluar
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.save_game()
	
	if Dialogic.current_timeline != null:
		Dialogic.current_timeline = null
		
	var bgm = get_node_or_null("/root/BGMManager")
	if bgm:
		bgm.play_track("main_menu")
		
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
