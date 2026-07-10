import os

filepath = 'scenes/maps/kamar_mc.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Add ext_resource at the end of ext_resources
last_ext_idx = 0
for i, line in enumerate(lines):
    if line.startswith('[ext_resource'):
        last_ext_idx = i

lines.insert(last_ext_idx + 1, '[ext_resource type="Script" path="res://scripts/kamar_mc_root.gd" id="99_root"]\n')

# Find node KamarMC
for i, line in enumerate(lines):
    if line.startswith('[node name="KamarMC" type="Node2D"'):
        lines.insert(i + 1, 'script = ExtResource("99_root")\n')
        break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Attached kamar_mc_root.gd to kamar_mc.tscn")
