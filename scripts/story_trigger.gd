extends Area2D

@export var timeline_name: String = ""
@export var timeline_per_hari: Array[String] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.day_changed.connect(_on_day_changed)
		
	# Khusus untuk TriggerBangun, kita masukkan ke grup dan paksa jalankan dialog
	if name == "TriggerBangun":
		add_to_group("WakingTrigger")
		call_deferred("force_trigger")

func _on_day_changed(new_day: int) -> void:
	set_deferred("monitoring", true)
	
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
		Dialogic.start(target_tl)
		set_deferred("monitoring", false)

func _on_body_entered(body: Node2D) -> void:
	# Jika yang menginjak adalah Player, dan dialog sedang tidak berjalan
	if body.is_in_group("Player"):
		var target_timeline = timeline_name
		
		# Jika ada timeline_per_hari yang di set, gunakan itu berdasarkan hari
		if timeline_per_hari.size() > 0:
			var current_day = StoryManager.current_day
			if current_day < timeline_per_hari.size():
				target_timeline = timeline_per_hari[current_day]
				
		if target_timeline != "" and not Dialogic.current_timeline:
			Dialogic.start(target_timeline)
			
			# Nonaktifkan sementara sensor ini agar tidak memicu berulang kali di hari yang sama
			set_deferred("monitoring", false)
