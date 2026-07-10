import os

filepath = 'scenes/maps/jalanan_kota.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

last_ext_idx = 0
for i, line in enumerate(lines):
    if line.startswith('[ext_resource'):
        last_ext_idx = i

lines.insert(last_ext_idx + 1, '[ext_resource type="Script" path="res://scripts/jalanan_kota_root.gd" id="99_root"]\n')

for i, line in enumerate(lines):
    if line.startswith('[node name="JalananKota" type="Node2D"'):
        lines.insert(i + 1, 'script = ExtResource("99_root")\n')
        break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Attached jalanan_kota_root.gd to jalanan_kota.tscn")
