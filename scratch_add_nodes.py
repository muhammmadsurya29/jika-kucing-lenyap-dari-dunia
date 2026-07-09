import re
import random
import string

def generate_id():
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))

def add_node_to_scene(filepath, node_name, timeline_name):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the interactable.gd ExtResource ID, or add it
    ext_id = None
    match = re.search(r'\[ext_resource type="Script" path="res://scripts/interactable\.gd" id="([^"]+)"\]', content)
    if match:
        ext_id = match.group(1)
    else:
        ext_id = generate_id()
        # Find the last ext_resource to insert after it
        last_ext_index = content.rfind('[ext_resource')
        if last_ext_index != -1:
            end_of_line = content.find('\n', last_ext_index)
            insert_str = f'\n[ext_resource type="Script" path="res://scripts/interactable.gd" id="{ext_id}"]'
            content = content[:end_of_line] + insert_str + content[end_of_line:]
        else:
            # If no ext_resource exists, insert after the first line (gd_scene)
            end_of_line = content.find('\n')
            insert_str = f'\n[ext_resource type="Script" path="res://scripts/interactable.gd" id="{ext_id}"]'
            content = content[:end_of_line] + insert_str + content[end_of_line:]

    # Generate the nodes
    new_nodes = f"""

[node name="{node_name}" type="Area2D" parent="."]
position = Vector2(0, 0)
script = ExtResource("{ext_id}")
timeline_name = "{timeline_name}"
required_day = 99

[node name="CollisionShape2D" type="CollisionShape2D" parent="{node_name}"]
shape = SubResource("RectangleShape2D_{generate_id()}")
"""

    # We also need a SubResource for the shape. 
    # Godot 4 uses subresources defined at the top, or we can use inline resources? No, inline shapes don't exist, we must use SubResource or built-in.
    # Actually, in .tscn we can define a SubResource at the top:
    # [sub_resource type="RectangleShape2D" id="RectangleShape2D_..."]
    # size = Vector2(40, 40)
    
    shape_id = "RectangleShape2D_" + generate_id()
    sub_resource_str = f'\n[sub_resource type="RectangleShape2D" id="{shape_id}"]\nsize = Vector2(40, 40)\n'
    
    # Insert sub_resource right after the last ext_resource
    last_ext_index = content.rfind('[ext_resource')
    if last_ext_index != -1:
        end_of_line = content.find('\n', last_ext_index)
        content = content[:end_of_line] + sub_resource_str + content[end_of_line:]

    new_nodes = f"""

[node name="{node_name}" type="Area2D" parent="."]
position = Vector2(0, 0)
script = ExtResource("{ext_id}")
timeline_name = "{timeline_name}"
required_day = 99

[node name="CollisionShape2D" type="CollisionShape2D" parent="{node_name}"]
shape = SubResource("{shape_id}")
"""

    content += new_nodes

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Successfully added {node_name} to {filepath}")

add_node_to_scene('scenes/maps/jalanan_kota.tscn', 'KotakPos', 'alt_mengantar_surat')
add_node_to_scene('scenes/maps/Taman_Bukit.tscn', 'BangkuBiru', 'alt_taman_bukit')
