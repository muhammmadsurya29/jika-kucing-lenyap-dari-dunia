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

func _ready() -> void:
	# Dengarkan ketika ada objek fisik yang menyentuh area pintu ini
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Ambil data hari dari StoryManager
		var sm = get_node_or_null("/root/StoryManager")
		var day = sm.current_day if sm else 1
		var can_leave = sm.can_leave_room if sm else true
		var cafe_done = sm.cafe_event_done if sm else false
		
		# Khusus Pintu Kamar di Hari 4 menuju pemakaman
		if target_scene == "res://scenes/maps/jalanan_kota.tscn" and day == 4 and sm.day4_state == "beres_beres_selesai":
			if has_node("/root/ScreenFade"):
				get_node("/root/ScreenFade").transition_to("res://scenes/maps/kantor_pemakaman.tscn", 1.0)
			else:
				get_tree().change_scene_to_file("res://scenes/maps/kantor_pemakaman.tscn")
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
				Dialogic.start(target_tl)
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
