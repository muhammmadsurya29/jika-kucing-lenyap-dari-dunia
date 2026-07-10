import re
import random
import string

def generate_id():
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))

filepath = 'scenes/maps/Taman_Bukit.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

new_nodes = f'''

[node name="NodeA_MC" type="Marker2D" parent="."]
position = Vector2(-50, 0)

[node name="NodeB_Kubis" type="Marker2D" parent="."]
position = Vector2(50, 0)

[node name="NodeSpawnAnak" type="Marker2D" parent="."]
position = Vector2(-200, -200)

[node name="NodeTitikAnak" type="Marker2D" parent="."]
position = Vector2(-10, -50)

[node name="NodeSpawnIbu" type="Marker2D" parent="."]
position = Vector2(-200, -180)

[node name="NodeTitikIbu" type="Marker2D" parent="."]
position = Vector2(-30, -70)
'''

content += new_nodes

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print(f"Successfully added 6 Marker2Ds to {filepath}")
