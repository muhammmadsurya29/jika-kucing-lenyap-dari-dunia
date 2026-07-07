extends Area2D
class_name Interactable

@export var timeline_name: String = ""
@export var timeline_per_hari: Array[String] = []
@export var titik_kumpul_per_hari: Array[NodePath] = []
@export var hapus_setelah_dialog: bool = false
@export var timeline_berikutnya: String = ""
@export var requires_daily_event: bool = false
@export var locked_timeline: String = ""

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
			
	# Munculkan/Sembunyikan NPC di hari baru
	var shape = get_node_or_null("CollisionShape2D")
	if has_dialog:
		show()
		if shape: shape.set_deferred("disabled", false)
	else:
		hide()
		if shape: shape.set_deferred("disabled", true)

func _on_dialogic_signal(argument: String) -> void:
	if argument == "npc_hilang" and hapus_setelah_dialog:
		# Buat animasi memudar (Tween)
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 1.5) # Memudar selama 1.5 detik
		
		# Setelah animasi selesai
		tween.finished.connect(func():
			if timeline_berikutnya != "":
				Dialogic.start(timeline_berikutnya)
			
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
		print("[DEBUG Interactable] Pemain menekan Space/Enter di area: ", self.name)
		if timeline_name != "" or not timeline_per_hari.is_empty():
			if not Dialogic.current_timeline:
				print("[DEBUG Interactable] Mempersiapkan timeline...")
			
			# --- FITUR NPC MENGHADAP PLAYER ---
			var player = get_tree().get_first_node_in_group("Player")
			var sprite = get_node_or_null("AnimatedSprite2D") # Sesuaikan nama node jika beda
			
			if player and sprite:
				var diff = player.global_position - global_position
				
				# Jika jarak horizontal lebih besar dari vertikal (berada di kiri/kanan)
				if abs(diff.x) > abs(diff.y):
					if diff.x > 0:
						sprite.play("idle_right")
					else:
						sprite.play("idle_left")
				# Jika jarak vertikal lebih besar (berada di atas/bawah)
				else:
					if diff.y > 0:
						sprite.play("idle_down")
					else:
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
			
			# --- PENGECEKAN SYARAT EVENT HARIAN ---
			if requires_daily_event:
				var sm_check = get_node_or_null("/root/StoryManager")
				if sm_check and not sm_check.can_sleep:
					if locked_timeline != "":
						print("[DEBUG Interactable] Memainkan locked_timeline: ", locked_timeline)
						Dialogic.start(locked_timeline)
					return # Hentikan proses, jangan putar dialog utama
			# --------------------------------------
			
			if tl_to_play != "" and tl_to_play != "IGNORE":
				print("[DEBUG Interactable] Memulai Dialogic: ", tl_to_play)
				if ":" in tl_to_play:
					var parts = tl_to_play.split(":")
					Dialogic.start(parts[0], parts[1])
				else:
					Dialogic.start(tl_to_play)
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
