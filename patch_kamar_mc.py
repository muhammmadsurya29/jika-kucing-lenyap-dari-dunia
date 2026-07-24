import sys

filepath = 'scenes/maps/kamar_mc.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# target_scene_per_hari = Array[String](["", "res://scenes/maps/jalanan_kota.tscn", "res://scenes/maps/toko_dvd.tscn", "res://scenes/maps/Taman_Bukit.tscn", ""])
old_str = 'target_scene_per_hari = Array[String](["", "res://scenes/maps/jalanan_kota.tscn", "res://scenes/maps/toko_dvd.tscn", "res://scenes/maps/Taman_Bukit.tscn", ""])'
new_str = 'target_scene_per_hari = Array[String](["", "res://scenes/maps/jalanan_kota.tscn", "res://scenes/maps/jalanan_kota.tscn", "res://scenes/maps/Taman_Bukit.tscn", ""])'

if old_str in content:
    content = content.replace(old_str, new_str)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Successfully patched kamar_mc.tscn")
else:
    print("Could not find the target string in kamar_mc.tscn")
