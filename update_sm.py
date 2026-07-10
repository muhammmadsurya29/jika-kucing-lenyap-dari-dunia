import os

filepath = 'scripts/story_manager.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_vars = '''var is_ending_c: bool = false
var is_kubis_lenyap: bool = false
var ending_c_state: String = ""
'''

for i, line in enumerate(lines):
    if line.startswith('var alt2_epilog:'):
        lines.insert(i + 1, new_vars)
        break

new_logic = '''	elif argument == "ending_kesepian":
		is_ending_c = true
		is_kubis_lenyap = false # Akan hilang di dalam dialog kamar_awal
		Dialogic.start("ending_c_kamar_awal")
	elif argument == "fade_kubis":
		is_kubis_lenyap = true
		var kubis = get_tree().get_root().find_child("NPC_Kubis", true, false)
		if kubis:
			var tween = get_tree().create_tween()
			tween.tween_property(kubis, "modulate:a", 0.0, 1.5)
			await tween.finished
			kubis.queue_free()
	elif argument == "ending_c_lanjut_pagi":
		current_day = 101 # Day 101 is used for ending C
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/kamar_mc.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
	elif argument == "ending_c_ke_bioskop":
		ending_c_state = "luar_bioskop"
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/jalan_malam_cutscene.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/jalan_malam_cutscene.tscn")
	elif argument == "ending_c_masuk_bioskop":
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/dalam_bioskop.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/dalam_bioskop.tscn")
	elif argument == "ending_c_keluar_bioskop":
		ending_c_state = "luar_bioskop_post"
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/jalan_malam_cutscene.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/jalan_malam_cutscene.tscn")
	elif argument == "ending_c_pulang":
		ending_c_state = "epilog"
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/maps/kamar_mc.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
	elif argument == "aloha_fade_in":
		var aloha = get_tree().get_root().find_child("NPC_Aloha", true, false)
		if aloha:
			aloha.show()
			aloha.modulate.a = 0.0
			var tween = get_tree().create_tween()
			tween.tween_property(aloha, "modulate:a", 1.0, 1.5)
	elif argument == "ending_c_credit":
		print(">> GAME TAMAT (ENDING KESEPIAN)!")
		if has_node("/root/ScreenFade"):
			get_node("/root/ScreenFade").transition_to("res://scenes/ui/credit_kesepian.tscn", 2.0)
		else:
			get_tree().change_scene_to_file("res://scenes/ui/credit_kesepian.tscn")
'''

for i, line in enumerate(lines):
    if 'elif argument == "alt2_credit_bangkit_start":' in line:
        lines.insert(i, new_logic)
        break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Updated story_manager.gd")
