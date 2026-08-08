extends Node2D

@onready var kubis = $NPC_Kubis
var player: Node2D

# Referensi NPC yang di-instantiate di hari 99
var npc_anak: Node2D = null
var npc_ibu: Node2D = null

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
var _off_canvas: CanvasLayer
var _off_sprite: Sprite2D

func _ready() -> void:
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	if marker_icon:
		_marker_sprite = Sprite2D.new()
		_marker_sprite.texture = marker_icon
		_marker_sprite.hframes = icon_hframes
		_marker_sprite.vframes = icon_vframes
		_marker_sprite.frame = icon_frame
		_marker_sprite.z_index = 50
		add_child(_marker_sprite)
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
		
	player = get_tree().get_first_node_in_group("Player")
	
	if StoryManager.current_day == 3:
		# Sembunyikan trigger taman default untuk mencegah tabrakan timeline
		var trigger_taman = get_node_or_null("TriggerTaman")
		if trigger_taman:
			trigger_taman.queue_free()
		
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.monitoring = false
			if not trigger_bangku.body_entered.is_connected(_on_trigger_bangku_body_entered):
				trigger_bangku.body_entered.connect(_on_trigger_bangku_body_entered)
				
		var trigger_bunga = get_node_or_null("TriggerBunga")
		if trigger_bunga:
			trigger_bunga.monitoring = true
			if not trigger_bunga.body_entered.is_connected(_on_trigger_bunga_body_entered):
				trigger_bunga.body_entered.connect(_on_trigger_bunga_body_entered)
		
		# Langsung jalankan animasi kubis ke arah bunga tanpa mengunci player
		_jalan_ke_kanan_anim()

	elif StoryManager.current_day == 99:
		# Setup Sinematik Hari 99
		# Kunci pergerakan langsung agar animasi tidak ditimpa oleh _physics_process
		if player and player.has_method("lock_movement"):
			player.lock_movement()
			
		var node_mc = get_node_or_null("NodeA_MC")
		if player and node_mc:
			player.global_position = node_mc.global_position
			if player.has_method("play_custom_animation"):
				player.play_custom_animation("sit_left")
		
		# Untuk Kubis
		# Jika kubis tidak ada (queue_free sebelumnya), maka kita perlu instansiasi jika perlu, 
		# Tapi di script ini kubis = $NPC_Kubis yang ada di scene sejak awal.
		if not kubis:
			var kubis_scene = load("res://scenes/characters/cat.tscn")
			if kubis_scene:
				kubis = kubis_scene.instantiate()
				add_child(kubis)
				
		var node_kubis = get_node_or_null("NodeB_Kubis")
		if kubis and node_kubis:
			kubis.global_position = node_kubis.global_position
			var anim = kubis.get_node_or_null("AnimatedSprite2D")
			if anim:
				anim.play("sit_down")
				
		# Sembunyikan trigger agar tidak ada interaksi manual
		var trigger_taman = get_node_or_null("TriggerTaman")
		if trigger_taman: trigger_taman.queue_free()
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku: trigger_bangku.queue_free()
		
		# Mainkan dialog otomatis setelah scene dimuat
		_play_alt_taman_bukit()

	else:
		# Jika bukan hari ke-3 atau 99, hapus trigger bangku khusus dan kubis
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.queue_free()
			
		if kubis:
			kubis.queue_free()

func _on_dialogic_signal(argument: String) -> void:
	if argument == "kubis_jalan_ke_bunga":
		_jalan_ke_kanan_anim()
	elif argument == "kubis_jalan_ke_bukit":
		_jalan_ke_atas_anim()
	elif argument == "aktifkan_bangku":
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.set_deferred("monitoring", true)
	elif argument == "aktifkan_bunga":
		var trigger_bunga = get_node_or_null("TriggerBunga")
		if trigger_bunga:
			trigger_bunga.set_deferred("monitoring", true)
	elif argument == "ganti_hari_langsung":
		var sm = get_node_or_null("/root/StoryManager")
		if sm:
			if sm.has_method("pulang_malam"):
				sm.pulang_malam("res://scenes/maps/kamar_mc.tscn")
			else:
				sm.ganti_hari("res://scenes/maps/kamar_mc.tscn")
	elif argument == "anak_muncul":
		_munculkan_anak()
	elif argument == "ibu_muncul":
		_munculkan_ibu()

func _munculkan_anak() -> void:
	var anak_scene = load("res://scenes/characters/kencur.tscn")
	if not anak_scene: return
	npc_anak = anak_scene.instantiate()
	add_child(npc_anak)
	
	var spawn = get_node_or_null("NodeSpawnAnak")
	var target = get_node_or_null("NodeTitikAnak")
	
	if spawn and target:
		npc_anak.global_position = spawn.global_position
		var anim = npc_anak.get_node_or_null("AnimatedSprite2D")
		if anim: anim.play("walk_down")
		
		var dist = spawn.global_position.distance_to(target.global_position)
		var time = dist / 60.0
		var tween = create_tween()
		tween.tween_property(npc_anak, "global_position", target.global_position, time)
		await tween.finished
		
		if anim: anim.play("idle_down")
		
	# Lanjutkan dialog
	Dialogic.VAR.set("anak_sampai", true)

func _munculkan_ibu() -> void:
	var ibu_scene = load("res://scenes/characters/ibu_kencur.tscn")
	if not ibu_scene: return
	npc_ibu = ibu_scene.instantiate()
	add_child(npc_ibu)
	
	var spawn = get_node_or_null("NodeSpawnIbu")
	var target = get_node_or_null("NodeTitikIbu")
	
	if spawn and target:
		npc_ibu.global_position = spawn.global_position
		var anim = npc_ibu.get_node_or_null("AnimatedSprite2D")
		if anim: anim.play("walk_down")
		
		var dist = spawn.global_position.distance_to(target.global_position)
		var time = dist / 60.0
		var tween = create_tween()
		tween.tween_property(npc_ibu, "global_position", target.global_position, time)
		await tween.finished
		
		if anim: anim.play("idle_down")
		
	# Lanjutkan dialog
	Dialogic.VAR.set("ibu_sampai", true)

func _jalan_ke_kanan_anim() -> void:
	if kubis:
		var anim = kubis.get_node_or_null("AnimatedSprite2D")
		if anim:
			anim.play("walk_down")
		
		var tween = create_tween()
		var target = get_node_or_null("NodeBungaRandaTapak")
		if target:
			tween.tween_property(kubis, "global_position", target.global_position, 5.0)
		else:
			tween.tween_property(kubis, "position:y", kubis.position.y + 80, 5.0)
		await tween.finished
		
		if anim:
			anim.play("idle_down")

func _jalan_ke_atas_anim() -> void:
	if kubis:
		var anim = kubis.get_node_or_null("AnimatedSprite2D")
		if anim:
			anim.play("walk_down")
		
		var tween = create_tween()
		var target = get_node_or_null("NodeBangkuKakek")
		if target:
			tween.tween_property(kubis, "global_position", target.global_position, 6.0)
		else:
			tween.tween_property(kubis, "position:y", kubis.position.y + 100, 6.0)
		await tween.finished
		
		if anim:
			anim.play("idle_down")

# Script dipanggil oleh Area2D bunga
func _on_trigger_bunga_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and StoryManager.current_day == 3:
		var trigger_bunga = get_node_or_null("TriggerBunga")
		if trigger_bunga:
			trigger_bunga.set_deferred("monitoring", false)
			
		if player and player.has_method("lock_movement"):
			player.lock_movement()
			
		if not Dialogic.current_timeline:
			DialogicHelper.play_vn("hari3_taman_bagian1")

# Script dipanggil oleh Area2D bangku
func _on_trigger_bangku_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and StoryManager.current_day == 3:
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.set_deferred("monitoring", false)
			
		if player and player.has_method("lock_movement"):
			player.lock_movement()
			
		if player and player.has_method("play_custom_animation"):
			player.play_custom_animation("sit_left")
			
		if not Dialogic.current_timeline:
			DialogicHelper.play_vn("hari3_taman_bagian2")

func _play_alt_taman_bukit() -> void:
	await get_tree().create_timer(1.0).timeout
	while Dialogic.current_timeline != null:
		await get_tree().create_timer(0.1).timeout
	if player and player.has_method("lock_movement"):
		player.lock_movement()
	DialogicHelper.play_vn("alt_taman_bukit")

func _process(delta: float) -> void:
	if StoryManager.current_day != 3:
		if _off_canvas: _off_canvas.visible = false
		if _marker_sprite: _marker_sprite.visible = false
		return
		
	var trigger_bunga = get_node_or_null("TriggerBunga")
	var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
	
	var active_trigger: Area2D = null
	if trigger_bunga and trigger_bunga.monitoring:
		active_trigger = trigger_bunga
	elif trigger_bangku and trigger_bangku.monitoring:
		active_trigger = trigger_bangku
		
	if active_trigger:
		if _marker_sprite:
			_marker_sprite.visible = true
			var shape = active_trigger.get_node_or_null("CollisionShape2D")
			var base_pos = shape.global_position if shape else active_trigger.global_position
			# Animasi naik turun menggunakan sin
			var y_bob = sin(Time.get_ticks_msec() / 1000.0 * PI * 2) * 4.0
			_marker_sprite.global_position = base_pos + icon_offset + Vector2(0, y_bob)
		
		if _off_sprite and _off_canvas:
			var camera = get_viewport().get_camera_2d()
			if camera:
				var ui_size = get_viewport_rect().size
				var canvas_transform = get_viewport().canvas_transform
				var target_screen_pos = canvas_transform * active_trigger.global_position
				
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
		if _marker_sprite: _marker_sprite.visible = false
		if _off_canvas: _off_canvas.visible = false
