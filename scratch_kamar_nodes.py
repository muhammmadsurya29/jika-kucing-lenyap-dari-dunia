import re
import random
import string

def generate_id():
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))

filepath = 'scenes/maps/kamar_mc.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

ext_id = generate_id()
last_ext_index = content.rfind('[ext_resource')
if last_ext_index != -1:
    end_of_line = content.find('\n', last_ext_index)
    insert_str = f'\n[ext_resource type="Script" path="res://scripts/npc_choreography.gd" id="{ext_id}"]'
    content = content[:end_of_line] + insert_str + content[end_of_line:]
else:
    end_of_line = content.find('\n')
    insert_str = f'\n[ext_resource type="Script" path="res://scripts/npc_choreography.gd" id="{ext_id}"]'
    content = content[:end_of_line] + insert_str + content[end_of_line:]

new_nodes = f'''

[node name="PointA" type="Marker2D" parent="."]
position = Vector2(50, 50)

[node name="PointB" type="Marker2D" parent="."]
position = Vector2(50, 100)

[node name="PointC" type="Marker2D" parent="."]
position = Vector2(100, 100)

[node name="PointD" type="Marker2D" parent="."]
position = Vector2(100, 150)

[node name="NPCChoreography" type="Node" parent="."]
script = ExtResource("{ext_id}")
point_a = NodePath("../PointA")
point_b = NodePath("../PointB")
point_c = NodePath("../PointC")
point_d = NodePath("../PointD")
'''

content += new_nodes

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print(f"Successfully added choreography nodes to {filepath}")
