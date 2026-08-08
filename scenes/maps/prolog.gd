extends Control

func _ready() -> void:
	# 1. Jalankan timeline babak 1 secara otomatis
	DialogicHelper.play_vn("prolog_vonis")
	
	# 2. Perintahkan sistem: "Kalau dialognya tamat, jalankan fungsi pindah_scene"
	Dialogic.timeline_ended.connect(_on_prolog_selesai)

func _on_prolog_selesai() -> void:
	# 3. Pindahkan pemain ke map top-down saat layar sudah hitam
	# Pastikan path ini mengarah ke map kamar MC/test_room Anda!
	get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
