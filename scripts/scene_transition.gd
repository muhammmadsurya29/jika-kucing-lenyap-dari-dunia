extends Area2D

# Variabel ini akan muncul di Inspector. 
# Anda tinggal mengklik ikon folder untuk memilih scene map tujuan (misal: jalanan_kota.tscn)
@export_file("*.tscn") var target_scene: String
@export var minimum_day_to_exit: int = 1
@export var requires_leave_permission: bool = false
@export var requires_cafe_event_done: bool = false
@export var locked_timeline: String = "pintu_terkunci"
@export var locked_timeline_per_hari: Array[String] = []
@export var target_scene_per_hari: Array[String] = []
@export var inactive_on_days: Array[int] = []

@export_group("UI Penunjuk Arah")
@export var marker_icon: Texture2D
@export var icon_hframes: int = 1
@export var icon_vframes: int = 1
@export var icon_frame: int = 0
@export var icon_offset: Vector2 = Vector2(0, -32)

@export_group("UI Panah Luar Layar")
@export var use_offscreen_pointer: bool = false
@export var pointer_texture: Texture2D
@export var pointer_hframes: int = 1
@export var pointer_vframes: int = 1
@export var pointer_scale: Vector2 = Vector2(1, 1)
@export var pointer_margin: float = 40.0
@export var frame_right: int = 0
@export var frame_left: int = 1
@export var frame_top_right: int = 2
@export var frame_top_left: int = 3

var _marker_sprite: Sprite2D
var _marker_tween: Tween

var _off_canvas: CanvasLayer
var _off_sprite: Sprite2D

func _ready() -> void:
	# Dengarkan ketika ada objek fisik yang menyentuh area pintu ini
	body_entered.connect(_on_body_entered)
	
	var sm = get_node_or_null("/root/StoryManager")
	var day = sm.current_day if sm else 1
	
	if day in inactive_on_days:
		use_offscreen_pointer = false
	
	if marker_icon:
		_marker_sprite = Sprite2D.new()
		_marker_sprite.texture = marker_icon
		_marker_sprite.hframes = icon_hframes
		_marker_sprite.vframes = icon_vframes
		_marker_sprite.frame = icon_frame
		_marker_sprite.z_index = 50
		add_child(_marker_sprite)
		
		var shape = get_node_or_null("CollisionShape2D")
		if shape:
			_marker_sprite.position = shape.position + icon_offset
		else:
			_marker_sprite.position = icon_offset
			
		_marker_tween = create_tween().set_loops()
		_marker_tween.tween_property(_marker_sprite, "position:y", _marker_sprite.position.y - 8, 0.6).set_trans(Tween.TRANS_SINE)
		_marker_tween.tween_property(_marker_sprite, "position:y", _marker_sprite.position.y, 0.6).set_trans(Tween.TRANS_SINE)
		
		if day in inactive_on_days:
			_marker_sprite.visible = false
		
	if use_offscreen_pointer and pointer_texture:
		_off_canvas = CanvasLayer.new()
		add_child(_off_canvas)
		
		_off_sprite = Sprite2D.new()
		_off_sprite.texture = pointer_texture
		_off_sprite.hframes = pointer_hframes
		_off_sprite.vframes = pointer_vframes
		_off_sprite.scale = pointer_scale
		_off_canvas.add_child(_off_sprite)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Ambil data hari dari StoryManager
		var sm = get_node_or_null("/root/StoryManager")
		var day = sm.current_day if sm else 1
		
		print("[DEBUG Pintu] Pintu ", self.name, " diinjak di Hari: ", day, " dengan day4_state: ", sm.day4_state if sm else "")
		print("[DEBUG Pintu] inactive_on_days berisi: ", inactive_on_days)
		
		if day in inactive_on_days:
			print("[DEBUG Pintu] Pintu dinonaktifkan pada hari ini! Membatalkan.")
			return
			
		var can_leave = sm.can_leave_room if sm else true
		var cafe_done = sm.cafe_event_done if sm else false
		
		# Khusus Pintu Pemakaman di Hari 4, hanya bisa diakses SETELAH beres-beres
		if target_scene == "res://scenes/maps/kantor_pemakaman.tscn" and day == 4:
			if sm and sm.day4_state != "beres_beres_selesai":
				if not Dialogic.current_timeline:
					DialogicHelper.play_vn("hari4_belum_beres")
				return

		# Khusus kembali ke kamar di Hari 99 (Ending Damai)
		if target_scene == "res://scenes/maps/kamar_mc.tscn" and day == 99:
			if has_node("/root/ScreenFade"):
				get_node("/root/ScreenFade").transition_to("res://scenes/maps/kamar_mc.tscn", 1.0)
			else:
				get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
			if sm and sm.has_method("play_alt_sore_kamar"):
				sm.play_alt_sore_kamar()
			return
			
		# Kunci pintu jika belum ada izin keluar (khusus pintu kamar) atau belum cukup hari
		if (requires_leave_permission and not can_leave) or (requires_cafe_event_done and not cafe_done) or day < minimum_day_to_exit:
			var target_tl = locked_timeline
			
			if locked_timeline_per_hari.size() > 0 and day < locked_timeline_per_hari.size():
				if locked_timeline_per_hari[day] != "":
					target_tl = locked_timeline_per_hari[day]
					
			if target_tl != "" and not Dialogic.current_timeline:
				DialogicHelper.play_vn(target_tl)
			return
		
		# Jika lolos syarat, pindah scene
		var final_target = target_scene
		if target_scene_per_hari.size() > 0 and day < target_scene_per_hari.size():
			if target_scene_per_hari[day] != "":
				final_target = target_scene_per_hari[day]
		if final_target != "":
			# Gunakan durasi lebih panjang untuk scene besar seperti jalanan_kota
			var duration = 0.5
			if "jalanan_kota" in final_target or "taman" in final_target:
				duration = 1.0
			
			if has_node("/root/ScreenFade"):
				get_node("/root/ScreenFade").transition_to(final_target, duration)
			else:
				get_tree().change_scene_to_file(final_target)

func _process(delta: float) -> void:
	var sm = get_node_or_null("/root/StoryManager")
	var day = sm.current_day if sm else 1
	var is_door_active = true
	if day in inactive_on_days:
		is_door_active = false
	if target_scene == "res://scenes/maps/kantor_pemakaman.tscn" and day == 4:
		if sm and sm.day4_state != "beres_beres_selesai":
			is_door_active = false
			
	if _marker_sprite:
		_marker_sprite.visible = is_door_active
		
	if _off_sprite and _off_canvas:
		var camera = get_viewport().get_camera_2d()
		if camera:
			var ui_size = get_viewport_rect().size
			var canvas_transform = get_viewport().canvas_transform
			var target_screen_pos = canvas_transform * global_position
			
			var screen_rect = Rect2(Vector2.ZERO, ui_size).grow(-20.0)
			
			if screen_rect.has_point(target_screen_pos) or not is_door_active:
				_off_canvas.visible = false
			else:
				_off_canvas.visible = true
				var center = ui_size / 2.0
				var dir = (target_screen_pos - center).normalized()
				
				var x_factor = (ui_size.x/2.0 - pointer_margin) / abs(dir.x) if dir.x != 0 else 10000.0
				var y_factor = (ui_size.y/2.0 - pointer_margin) / abs(dir.y) if dir.y != 0 else 10000.0
				var factor = min(x_factor, y_factor)
				
				_off_sprite.position = center + dir * factor
				
				var deg = rad_to_deg(dir.angle())
				_off_sprite.rotation = 0
				_off_sprite.flip_v = false
				
				if deg >= -22.5 and deg < 22.5: # Kanan
					_off_sprite.frame = frame_right
				elif deg >= 22.5 and deg < 67.5: # Kanan Bawah
					_off_sprite.frame = frame_top_right
					_off_sprite.flip_v = true
				elif deg >= 67.5 and deg < 112.5: # Bawah
					_off_sprite.frame = frame_right
					_off_sprite.rotation = PI/2
				elif deg >= 112.5 and deg < 157.5: # Kiri Bawah
					_off_sprite.frame = frame_top_left
					_off_sprite.flip_v = true
				elif deg >= 157.5 or deg < -157.5: # Kiri
					_off_sprite.frame = frame_left
				elif deg >= -157.5 and deg < -112.5: # Kiri Atas
					_off_sprite.frame = frame_top_left
				elif deg >= -112.5 and deg < -67.5: # Atas
					_off_sprite.frame = frame_right
					_off_sprite.rotation = -PI/2
				elif deg >= -67.5 and deg < -22.5: # Kanan Atas
					_off_sprite.frame = frame_top_right
		else:
			_off_canvas.visible = false
