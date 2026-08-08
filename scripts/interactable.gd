extends Area2D
class_name Interactable

@export var timeline_name: String = ""
@export var timeline_per_hari: Array[String] = []
@export var titik_kumpul_per_hari: Array[NodePath] = []
@export var hapus_setelah_dialog: bool = false
@export var timeline_berikutnya: String = ""
@export var requires_daily_event: bool = false
@export var locked_timeline: String = ""
@export var active_in_day4_climax: bool = false

@export_group("UI Tanda Pentung")
@export var interact_icon: Texture2D
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

var _icon_sprite: Sprite2D
var _icon_tween: Tween

var _off_canvas: CanvasLayer
var _off_sprite: Sprite2D

# Variabel untuk AI Follower (Mengikuti)
var is_following_player: bool = false
var is_moving: bool = false
var follow_speed: float = 75.0
var follow_distance: float = 45.0
var stop_distance: float = 30.0

var is_player_in_range: bool = false

func _ready() -> void:
	# Hubungkan sinyal tabrakan Area2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Dengarkan sinyal dari Dialogic
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	
	# Setup UI Tanda Pentung
	if interact_icon:
		_icon_sprite = Sprite2D.new()
		_icon_sprite.texture = interact_icon
		_icon_sprite.hframes = icon_hframes
		_icon_sprite.vframes = icon_vframes
		_icon_sprite.frame = icon_frame
		_icon_sprite.z_index = 50 # Di atas karakter
		add_child(_icon_sprite)
		
		var shape = get_node_or_null("CollisionShape2D")
		if shape:
			_icon_sprite.position = shape.position + icon_offset
		else:
			_icon_sprite.position = icon_offset
			
		_icon_sprite.visible = false # Akan diatur oleh _on_day_changed
		_icon_tween = create_tween().set_loops()
		_icon_tween.tween_property(_icon_sprite, "position:y", _icon_sprite.position.y - 8, 0.6).set_trans(Tween.TRANS_SINE)
		_icon_tween.tween_property(_icon_sprite, "position:y", _icon_sprite.position.y, 0.6).set_trans(Tween.TRANS_SINE)
		
	if use_offscreen_pointer and pointer_texture:
		_off_canvas = CanvasLayer.new()
		add_child(_off_canvas)
		
		_off_sprite = Sprite2D.new()
		_off_sprite.texture = pointer_texture
		_off_sprite.hframes = pointer_hframes
		_off_sprite.vframes = pointer_vframes
		_off_sprite.scale = pointer_scale
		_off_canvas.add_child(_off_sprite)
		
	# Dengarkan sinyal ganti hari dari StoryManager
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.day_changed.connect(_on_day_changed)
		_on_day_changed(sm.current_day) # Terapkan posisi dan visibilitas awal

func _on_day_changed(new_day: int) -> void:
	var index = new_day
	
	# Pindahkan posisi NPC menggunakan titik penanda (Marker2D) yang ada di map
	if not titik_kumpul_per_hari.is_empty():
		if index >= 0 and index < titik_kumpul_per_hari.size():
			var jalur_node = titik_kumpul_per_hari[index]
			if not jalur_node.is_empty():
				var target = get_node_or_null(jalur_node)
				if target:
					global_position = target.global_position
					
	# Cek apakah NPC ini punya dialog hari ini
	var has_dialog = true
	if not timeline_per_hari.is_empty():
		if index >= 0 and index < timeline_per_hari.size():
			if timeline_per_hari[index] == "":
				has_dialog = false
		else:
			has_dialog = false
			
	# Cek apakah timeline ini sudah pernah dimainkan
	var sm = get_node_or_null("/root/StoryManager")
	var is_active = has_dialog
	if is_active and sm:
		var current_tl = timeline_name
		if not timeline_per_hari.is_empty() and index >= 0 and index < timeline_per_hari.size():
			current_tl = timeline_per_hari[index]
		
		if current_tl != "" and sm.has_played(current_tl):
			is_active = false
			
		# Matikan semua interaksi usang di fase klimaks Hari 4
		var is_climax_active = active_in_day4_climax or self.name == "Kasur" or self.name == "Meja"
		if sm.current_day == 4 and sm.day4_state != "" and not is_climax_active:
			is_active = false
			
	# Munculkan/Sembunyikan NPC di hari baru
	var shape = get_node_or_null("CollisionShape2D")
	if has_dialog:
		show()
		if shape: shape.set_deferred("disabled", false)
		if _icon_sprite: _icon_sprite.visible = is_active
	else:
		hide()
		if shape: shape.set_deferred("disabled", true)
		if _icon_sprite: _icon_sprite.visible = false

func _on_dialogic_signal(argument: String) -> void:
	if argument == "npc_hilang" and hapus_setelah_dialog:
		# Buat animasi memudar (Tween)
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 1.5) # Memudar selama 1.5 detik
		
		# Setelah animasi selesai
		tween.finished.connect(func():
			if timeline_berikutnya != "":
				DialogicHelper.play_map(timeline_berikutnya)
			
			# Jangan dihapus, tapi disembunyikan agar bisa muncul besok
			hide()
			var shape = get_node_or_null("CollisionShape2D")
			if shape: shape.set_deferred("disabled", true)
			
			# Reset transparansi untuk persiapan besok
			modulate.a = 1.0
		)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("[DEBUG Interactable] Player masuk ke area: ", self.name)
		is_player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("[DEBUG Interactable] Player keluar dari area: ", self.name)
		is_player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if is_player_in_range and event.is_action_pressed("ui_accept"):
		# Jika dialog sedang berjalan, abaikan input agar kotak trigger tidak terpicu ulang
		if Dialogic.current_timeline != null:
			return
			
		get_viewport().set_input_as_handled()
		print("[DEBUG Interactable] Pemain menekan Space/Enter di area: ", self.name)
		
		# Sembunyikan tanda pentung saat dialog mulai
		if _icon_sprite:
			_icon_sprite.visible = false
				
		if timeline_name != "" or not timeline_per_hari.is_empty():
			
			# --- FITUR NPC MENGHADAP PLAYER ---
			var player = get_tree().get_first_node_in_group("Player")
			var sprite = get_node_or_null("AnimatedSprite2D") # Sesuaikan nama node jika beda
			
			if player and sprite:
				var diff = player.global_position - global_position
				
				# Jika jarak horizontal lebih besar dari vertikal (berada di kiri/kanan)
				if abs(diff.x) > abs(diff.y):
					if diff.x > 0:
						if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle_right"):
							sprite.play("idle_right")
					else:
						if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle_left"):
							sprite.play("idle_left")
				# Jika jarak vertikal lebih besar (berada di atas/bawah)
				else:
					if diff.y > 0:
						if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle_down"):
							sprite.play("idle_down")
					else:
						if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle_up"):
							sprite.play("idle_up")
			# ----------------------------------
			
			# Tentukan timeline mana yang dimainkan berdasarkan hari
			var tl_to_play = timeline_name
			var sm = get_node_or_null("/root/StoryManager")
			if sm and not timeline_per_hari.is_empty():
				var index = sm.current_day
				if index >= 0 and index < timeline_per_hari.size():
					if timeline_per_hari[index] != "":
						tl_to_play = timeline_per_hari[index]
			
			print("[DEBUG Interactable] Timeline yang terpilih: ", tl_to_play)
			
			# Khusus Hari 4 akhir game (Menulis surat) di Kasur/Meja
			if sm and sm.current_day == 4 and sm.day4_state != "":
				var is_climax_active = active_in_day4_climax or self.name == "Kasur" or self.name == "Meja"
				if is_climax_active:
					if sm.day4_state == "pemakaman_selesai":
						tl_to_play = "hari4_true_ending:ending_surat"
						requires_daily_event = false # Abaikan syarat tidur
					else:
						# Belum dari pemakaman, abaikan interaksi kasur
						return
				else:
					# Nonaktifkan mesin cuci, jendela, dll di fase klimaks
					return
			
			# --- PENGECEKAN SYARAT EVENT HARIAN ---
			if requires_daily_event:
				var sm_check = get_node_or_null("/root/StoryManager")
				if sm_check and not sm_check.can_sleep:
					if locked_timeline != "":
						print("[DEBUG Interactable] Memainkan locked_timeline: ", locked_timeline)
						DialogicHelper.play_map(locked_timeline)
					return # Hentikan proses, jangan putar dialog utama
			# --------------------------------------
			
			if tl_to_play != "" and tl_to_play != "IGNORE":
				if sm:
					if tl_to_play != "kasur_malam" and sm.has_played(tl_to_play):
						print("[DEBUG Interactable] Timeline sudah pernah dimainkan, dilewati: ", tl_to_play)
						return
					sm.mark_played(tl_to_play)
				
				print("[DEBUG Interactable] Memulai Dialogic: ", tl_to_play)
				if ":" in tl_to_play:
					var parts = tl_to_play.split(":")
					DialogicHelper.play_map(parts[0], parts[1])
				else:
					DialogicHelper.play_map(tl_to_play)
			else:
				print("[DEBUG Interactable] tl_to_play KOSONG atau IGNORE! Batal menjalankan Dialogic.")

# ==============================================================================
# LOGIKA CUTSCENE & AI FOLLOWER
# ==============================================================================

func walk_to_target(target_pos: Vector2, duration: float) -> void:
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		var diff = target_pos - global_position
		if abs(diff.x) > abs(diff.y):
			sprite.play("walk_right" if diff.x > 0 else "walk_left")
		else:
			sprite.play("walk_down" if diff.y > 0 else "walk_up")
			
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, duration)
	await tween.finished
	
	if sprite:
		var diff = get_tree().get_first_node_in_group("Player").global_position - global_position
		if abs(diff.x) > abs(diff.y):
			sprite.play("idle_right" if diff.x > 0 else "idle_left")
		else:
			sprite.play("idle_down" if diff.y > 0 else "idle_up")

func _physics_process(delta: float) -> void:
	if not is_following_player:
		return
		
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return
		
	var dist = global_position.distance_to(player.global_position)
	var sprite = get_node_or_null("AnimatedSprite2D")
	
	# Hysteresis (Jeda agar tidak maju-berhenti setiap frame)
	if is_moving:
		if dist <= stop_distance:
			is_moving = false
	else:
		if dist > follow_distance:
			is_moving = true
	
	if is_moving:
		# Bergerak mendekati pemain
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * follow_speed * delta
		
		# Animasi jalan (jangan restart animasi berulang jika sudah jalan ke arah itu)
		if sprite:
			var anim_name = ""
			if abs(direction.x) > abs(direction.y):
				anim_name = "walk_right" if direction.x > 0 else "walk_left"
			else:
				anim_name = "walk_down" if direction.y > 0 else "walk_up"
				
			if sprite.animation != anim_name:
				sprite.play(anim_name)
	else:
		# Berhenti dan menghadap pemain
		if sprite:
			var diff = player.global_position - global_position
			var idle_anim = ""
			if abs(diff.x) > abs(diff.y):
				idle_anim = "idle_right" if diff.x > 0 else "idle_left"
			else:
				idle_anim = "idle_down" if diff.y > 0 else "idle_up"
				
			if sprite.animation != idle_anim:
				sprite.play(idle_anim)

func _process(delta: float) -> void:
	if _off_sprite and _off_canvas:
		if _icon_sprite and _icon_sprite.visible:
			var camera = get_viewport().get_camera_2d()
			if camera:
				var ui_size = get_viewport_rect().size
				var canvas_transform = get_viewport().canvas_transform
				var target_screen_pos = canvas_transform * global_position
				
				# Tambahkan margin kecil agar panah hilang saat objek "benar-benar" masuk layar
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
		else:
			_off_canvas.visible = false
