extends Area2D
class_name InteractableObject

@export var is_active: bool = true:
	set(value):
		is_active = value
		if _indicator:
			_indicator.visible = value
@export var timeline_name: String = ""
@export var popup_image: Texture2D
@export_multiline var popup_description: String = ""
@export var hover_modulate: Color = Color(1.2, 1.2, 1.2, 1.0) # Sedikit lebih terang saat di-hover

var _is_hovered: bool = false
var _original_modulate: Color = Color.WHITE
var _has_interacted: bool = false
var _sprite: CanvasItem = null
var _indicator: Label = null
var _base_indicator_y: float = -30.0

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Cari sprite anak (Sprite2D atau AnimatedSprite2D) untuk dimanipulasi warnanya
	for child in get_children():
		if child is Sprite2D or child is AnimatedSprite2D or child is ColorRect or child is TextureRect:
			_sprite = child
			break
			
	if _sprite:
		_original_modulate = _sprite.modulate
		
	_create_indicator()

func _create_indicator() -> void:
	_indicator = Label.new()
	_indicator.text = "[ KLIK ]"
	_indicator.add_theme_font_size_override("font_size", 20)
	_indicator.add_theme_color_override("font_color", Color.YELLOW)
	_indicator.add_theme_color_override("font_outline_color", Color.BLACK)
	_indicator.add_theme_constant_override("outline_size", 4)
	
	_indicator.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_indicator.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if _sprite and _sprite.get_class() == "Sprite2D" and _sprite.texture != null:
		_base_indicator_y = -(_sprite.texture.get_height() / 2.0) - 20.0
	else:
		_base_indicator_y = -30.0
		
	_indicator.position = Vector2(-4, _base_indicator_y)
	_indicator.z_index = 10
	
	add_child(_indicator)
	
	var tween = create_tween().set_loops()
	tween.tween_property(_indicator, "position:y", _base_indicator_y - 5.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_indicator, "position:y", _base_indicator_y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	_indicator.visible = is_active

func _on_mouse_entered() -> void:
	if not is_active:
		return
		
	_is_hovered = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
	if _sprite:
		_sprite.modulate = hover_modulate

func _on_mouse_exited() -> void:
	_is_hovered = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	if _sprite:
		_sprite.modulate = _original_modulate

func _input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not is_active:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()
		interact()

func interact() -> void:
	if Dialogic.current_timeline != null:
		return
		
	# Cek apakah sudah pernah diinteraksi (jika menggunakan Dialogic Variable)
	if (popup_image != null or popup_description != "") and timeline_name == "":
		_show_custom_popup()
	elif timeline_name != "":
		Dialogic.start(timeline_name)
		
	# Reset state kursor setelah interaksi
	_on_mouse_exited()

func _show_custom_popup() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().current_scene.add_child(canvas)
	
	# Background gelap
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(bg)
	
	# CenterContainer untuk memastikan semua berada di tengah dengan akurat
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(center)
	
	# Panel utama
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	panel.add_child(vbox)
	
	# Tambahkan gambar jika ada
	if popup_image != null:
		var tex_rect = TextureRect.new()
		tex_rect.texture = popup_image
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.custom_minimum_size = Vector2(300, 200) # Ukuran maksimal gambar
		vbox.add_child(tex_rect)
		
	# Tambahkan teks jika ada
	if popup_description != "":
		var lbl = Label.new()
		lbl.text = popup_description
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.custom_minimum_size = Vector2(300, 0)
		lbl.add_theme_font_size_override("font_size", 20)
		vbox.add_child(lbl)
		
	# Tombol tutup
	var close_btn = Button.new()
	close_btn.text = "Tutup"
	close_btn.custom_minimum_size = Vector2(150, 40)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(canvas.queue_free)
	vbox.add_child(close_btn)
	
	# Animasi muncul
	panel.scale = Vector2(0.5, 0.5)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "scale", Vector2(1, 1), 0.3)
