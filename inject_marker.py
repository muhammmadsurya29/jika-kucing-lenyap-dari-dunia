import os

filepath = 'scenes/maps/jalan_malam_cutscene.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_nodes = '''
[node name="NodeMCEndingC_Luar" type="Marker2D" parent="."]
position = Vector2(438, 68)

[node name="NodeMantanEndingC_Luar" type="Marker2D" parent="."]
position = Vector2(448, 65)

[node name="NodeMCEndingC_Post" type="Marker2D" parent="."]
position = Vector2(438, 68)

[node name="NodeMantanEndingC_Post" type="Marker2D" parent="."]
position = Vector2(468, 68)
'''

lines.append(new_nodes)

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Injected new Marker2D nodes into jalan_malam_cutscene.tscn")
