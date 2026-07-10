import os

filepath = 'scenes/maps/jalan_malam_cutscene.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

nodes_to_add = '''
[node name="NodeMCBerdiriMalam" type="Marker2D" parent="."]
position = Vector2(810, 40)

[node name="NodeMantanBerdiriMalam" type="Marker2D" parent="."]
position = Vector2(840, 40)
'''

lines.append(nodes_to_add)

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Added new standing nodes")
