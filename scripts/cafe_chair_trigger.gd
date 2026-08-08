extends Area2D

@export var timeline_to_play: String = "hari1_siang_cafe"

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
	body_entered.connect(_on_body_entered)
	
	# Sembunyikan dan nonaktifkan jika event sudah pernah dilakukan
	if StoryManager.cafe_event_done:
		queue_free()
		return
		
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
	if body.is_in_group("Player") and not StoryManager.cafe_event_done:
		if _marker_sprite:
			_marker_sprite.visible = false
			
		# Mencegah trigger terpanggil berkali-kali
		set_deferred("monitoring", false)
		
		# Mengunci pergerakan pemain
		if body.has_method("lock_movement"):
			body.lock_movement()
			
		# Menge-snap (menarik) pemain agar pas berada di tengah kursi
		body.global_position = global_position
		
		# Mainkan animasi duduk menghadap kanan
		if body.has_method("play_custom_animation"):
			body.play_custom_animation("sit_right")
		elif body.has_node("AnimatedSprite2D"):
			body.get_node("AnimatedSprite2D").play("sit_right")
			
		# Cari NPC Mantan dan posisi kursi Mantan
		var mantan = get_node_or_null("../NPC_Mantan")
		var marker_mantan = get_node_or_null("../MarkerKursiMantan")
		
		if mantan and marker_mantan:
			# Matikan AI Follower sementara agar tidak konflik dengan Tween jalan
			if "is_following_player" in mantan:
				mantan.is_following_player = false
				mantan.is_moving = false
				
			# NPC berjalan otomatis menuju kursinya (dengan opsi titik belok agar tidak nabrak meja)
			if mantan.has_method("walk_to_target"):
				var marker_jalan = get_node_or_null("../MarkerJalanMantan")
				if marker_jalan:
					await mantan.walk_to_target(marker_jalan.global_position, 1.0)
				await mantan.walk_to_target(marker_mantan.global_position, 1.5)
			else:
				mantan.global_position = marker_mantan.global_position
				
			# Setelah sampai, mainkan animasi NPC duduk menghadap kiri
			if mantan.has_node("AnimatedSprite2D"):
				mantan.get_node("AnimatedSprite2D").play("sit_left")
				
		# Jeda sejenak agar lebih dramatis
		await get_tree().create_timer(0.5).timeout
		
		# Mulai Dialog
		if not Dialogic.current_timeline:
			DialogicHelper.play_vn(timeline_to_play)
			Dialogic.timeline_ended.connect(_on_dialog_ended)

func _on_dialog_ended() -> void:
	# Dialog selesai
	Dialogic.timeline_ended.disconnect(_on_dialog_ended)
	
	# Tandai bahwa cutscene cafe hari ini sudah selesai
	StoryManager.cafe_event_done = true
	
	# Kembalikan kontrol pemain
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("unlock_movement"):
		player.unlock_movement()
		if player.has_method("play_idle_animation"):
			player.play_idle_animation()
			
	# Kembalikan NPC ke idle dan aktifkan kembali AI Follower
	var mantan = get_node_or_null("../NPC_Mantan")
	if mantan:
		if mantan.has_node("AnimatedSprite2D"):
			mantan.get_node("AnimatedSprite2D").play("idle_down")
		if "is_following_player" in mantan:
			mantan.is_following_player = true
	
	# Hapus area trigger agar tidak menumpuk
	queue_free()

func _process(delta: float) -> void:
	if _off_sprite and _off_canvas:
		var camera = get_viewport().get_camera_2d()
		if camera:
			var ui_size = get_viewport_rect().size
			var canvas_transform = get_viewport().canvas_transform
			var target_screen_pos = canvas_transform * global_position
			
			var screen_rect = Rect2(Vector2.ZERO, ui_size).grow(-20.0)
			
			if screen_rect.has_point(target_screen_pos):
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
