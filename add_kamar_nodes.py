import os

filepath = 'scenes/maps/kamar_mc.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

nodes_to_add = '''
[node name="NodeMCEpilogDuduk" type="Marker2D" parent="."]
position = Vector2(80, 50)

[node name="NodeKubisEpilogTidur" type="Marker2D" parent="."]
position = Vector2(9, 25)

[node name="NodeMCEpilogTidur" type="Marker2D" parent="."]
position = Vector2(9, 25)
'''

lines.append(nodes_to_add)

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Added Marker2D nodes to kamar_mc.tscn")
