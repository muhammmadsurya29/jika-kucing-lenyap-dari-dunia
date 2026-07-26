extends Area2D

@export var timeline_name: String = ""
@export var timeline_per_hari: Array[String] = []

@export_group("UI Penunjuk Arah")
@export var marker_icon: Texture2D
@export var icon_hframes: int = 1
@export var icon_vframes: int = 1
@export var icon_frame: int = 0
@export var icon_offset: Vector2 = Vector2(0, -32)

var _marker_sprite: Sprite2D
var _marker_tween: Tween

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
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
			
		_marker_sprite.visible = false
		_marker_tween = create_tween().set_loops()
		_marker_tween.tween_property(_marker_sprite, "position:y", _marker_sprite.position.y - 8, 0.6).set_trans(Tween.TRANS_SINE)
		_marker_tween.tween_property(_marker_sprite, "position:y", _marker_sprite.position.y, 0.6).set_trans(Tween.TRANS_SINE)
	
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.day_changed.connect(_on_day_changed)
		_on_day_changed(sm.current_day)
		
	# Khusus untuk TriggerBangun, kita masukkan ke grup dan paksa jalankan dialog
	if name == "TriggerBangun":
		add_to_group("WakingTrigger")
		if not StoryManager.is_night:
			var skip = false
			if StoryManager.current_day == 4 and StoryManager.day4_state != "":
				skip = true
			if not skip:
				call_deferred("force_trigger")

func _on_day_changed(new_day: int) -> void:
	set_deferred("monitoring", true)
	
	# Cek apakah timeline ini masih aktif
	var is_active = false
	var target_timeline = timeline_name
	if timeline_per_hari.size() > 0 and new_day < timeline_per_hari.size():
		target_timeline = timeline_per_hari[new_day]
		
	if target_timeline != "":
		is_active = true
		var sm = get_node_or_null("/root/StoryManager")
		if sm and sm.has_played(target_timeline):
			is_active = false
			
	if _marker_sprite:
		_marker_sprite.visible = is_active
	
	# Paksa jalankan dialog secara eksplisit tanpa mengandalkan physics engine
	if name == "TriggerBangun":
		force_trigger()

func force_trigger() -> void:
	var target_timeline = timeline_name
	
	if timeline_per_hari.size() > 0:
		var current_day = StoryManager.current_day
		if current_day < timeline_per_hari.size():
			target_timeline = timeline_per_hari[current_day]
			
	if target_timeline != "":
		_wait_and_start(target_timeline)

func _wait_and_start(target_tl: String) -> void:
	# Tunggu sampai timeline sebelumnya benar-benar bersih
	while Dialogic.current_timeline != null:
		await get_tree().create_timer(0.1).timeout
		
	if StoryManager.current_day >= 2:
		# Biarkan MC melakukan animasi melompat dari kasur terlebih dahulu
		await get_tree().create_timer(1.5).timeout
		
	if not Dialogic.current_timeline:
		var sm = get_node_or_null("/root/StoryManager")
		if sm:
			if sm.has_played(target_tl):
				print("[DEBUG StoryTrigger] (force) Timeline sudah pernah dimainkan, dilewati: ", target_tl)
				return
			sm.mark_played(target_tl)
		
		if ":" in target_tl:
			var parts = target_tl.split(":")
			Dialogic.start(parts[0], parts[1])
		else:
			Dialogic.start(target_tl)
		set_deferred("monitoring", false)

func _on_body_entered(body: Node2D) -> void:
	if StoryManager.is_night:
		return
		
	# Jika yang menginjak adalah Player, dan dialog sedang tidak berjalan
	if body.is_in_group("Player"):
		if name == "TriggerBangun" and StoryManager.current_day == 4 and Dialogic.VAR.get("day4_state") != "":
			return
			
		print("[DEBUG StoryTrigger] Player menginjak: ", self.name)
		var target_timeline = timeline_name
		
		# Jika ada timeline_per_hari yang di set, gunakan itu berdasarkan hari
		if timeline_per_hari.size() > 0:
			var current_day = StoryManager.current_day
			if current_day < timeline_per_hari.size():
				target_timeline = timeline_per_hari[current_day]
				
		if StoryManager.current_day == 101 and self.name == "TriggerDapurDay101":
			target_timeline = "ending_c_pagi_dapur"
			
		print("[DEBUG StoryTrigger] Target timeline: ", target_timeline)
		
		if target_timeline != "" and not Dialogic.current_timeline:
			if _marker_sprite:
				_marker_sprite.visible = false
				
			var sm = get_node_or_null("/root/StoryManager")
			if sm:
				if sm.has_played(target_timeline):
					print("[DEBUG StoryTrigger] Timeline sudah pernah dimainkan, dilewati: ", target_timeline)
					return
				sm.mark_played(target_timeline)
			
			print("[DEBUG StoryTrigger] Memulai Dialogic: ", target_timeline)
			if ":" in target_timeline:
				var parts = target_timeline.split(":")
				Dialogic.start(parts[0], parts[1])
			else:
				Dialogic.start(target_timeline)
			
			# Nonaktifkan sementara sensor ini agar tidak memicu berulang kali di hari yang sama
			set_deferred("monitoring", false)
		else:
			print("[DEBUG StoryTrigger] Gagal memulai! Alasan: timeline KOSONG atau Dialogic SEDANG AKTIF.")
