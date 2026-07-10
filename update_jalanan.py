import os

filepath = 'scenes/maps/jalanan_kota.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

sub_resource = '''
[sub_resource type="GDScript" id="GDScript_alt2"]
script/source = "extends Node\\n\\nfunc _ready():\\n\\tawait get_tree().create_timer(1.0).timeout\\n\\tif StoryManager.current_day == 100:\\n\\t\\tvar player = get_tree().get_first_node_in_group('Player')\\n\\t\\tif player and player.has_method('lock_movement'):\\n\\t\\t\\tplayer.lock_movement()\\n\\t\\tDialogic.start('alt2_jalanan_kota')\\n"
'''

node = '''
[node name="Alt2Trigger" type="Node" parent="."]
script = SubResource("GDScript_alt2")
'''

# We need to insert the sub_resource right after the ext_resource lines and before the first node
ext_resource_end = content.rfind('[ext_resource')
if ext_resource_end != -1:
    end_of_line = content.find('\\n', ext_resource_end)
    content = content[:end_of_line+1] + sub_resource + content[end_of_line+1:]
else:
    # If no ext_resource, insert after the first line
    first_line_end = content.find('\\n')
    content = content[:first_line_end+1] + sub_resource + content[first_line_end+1:]

# Now append the node at the very end
content += node

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated jalanan_kota.tscn")
