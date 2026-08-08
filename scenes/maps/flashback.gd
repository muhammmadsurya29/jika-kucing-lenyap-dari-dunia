extends Control

func _ready() -> void:
	# Memulai kilas balik
	DialogicHelper.play_vn("babak3_flashback")
	
	# Tunggu sampai dialog selesai
	Dialogic.timeline_ended.connect(_on_flashback_selesai)

func _on_flashback_selesai() -> void:
	# Setelah selesai, kembalikan pemain ke map atau pindah hari
	get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
