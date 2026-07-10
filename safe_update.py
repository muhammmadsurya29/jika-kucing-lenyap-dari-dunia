import os

filepath = 'scenes/maps/jalanan_kota.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

sub_resource = '''
[sub_resource type="GDScript" id="GDScript_alt2"]
script/source = "extends Node\\n\\nfunc _ready():\\n\\tawait get_tree().create_timer(1.0).timeout\\n\\tif StoryManager.current_day == 100:\\n\\t\\tvar player = get_tree().get_first_node_in_group('Player')\\n\\t\\tif player and player.has_method('lock_movement'):\\n\\t\\t\\tplayer.lock_movement()\\n\\t\\tDialogic.start('alt2_jalanan_kota')\\n"
'''

node = '''
[node name="Alt2Trigger" type="Node" parent="."]
script = SubResource("GDScript_alt2")
'''

# Find the first [node name=
insert_idx = -1
for i, line in enumerate(lines):
    if line.startswith('[node name='):
        insert_idx = i
        break

if insert_idx != -1:
    lines.insert(insert_idx, sub_resource)

# Add node at the end
lines.append(node)

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Updated jalanan_kota.tscn successfully")
