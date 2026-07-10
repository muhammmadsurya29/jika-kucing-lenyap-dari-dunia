import re

filepath = 'scenes/maps/jalanan_kota.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
sub_resource_lines = []
in_sub_resource = False

for line in lines:
    if line.startswith('[sub_resource type="GDScript" id="GDScript_alt2"]'):
        in_sub_resource = True
        sub_resource_lines.append(line)
    elif in_sub_resource:
        sub_resource_lines.append(line)
        if line.strip() == '"':
            in_sub_resource = False
    else:
        new_lines.append(line)

# Now find the last ext_resource in new_lines
insert_idx = -1
for i in range(len(new_lines)-1, -1, -1):
    if new_lines[i].startswith('[ext_resource'):
        insert_idx = i + 1
        break

if insert_idx != -1 and sub_resource_lines:
    new_lines = new_lines[:insert_idx] + ['\n'] + sub_resource_lines + new_lines[insert_idx:]
elif sub_resource_lines:
    # fallback, just put it before first [node
    for i in range(len(new_lines)):
        if new_lines[i].startswith('[node'):
            insert_idx = i
            break
    if insert_idx != -1:
        new_lines = new_lines[:insert_idx] + sub_resource_lines + ['\n'] + new_lines[insert_idx:]

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print("Fixed jalanan_kota.tscn formatting!")
