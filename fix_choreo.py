import os

filepath = 'scripts/npc_choreography.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if line.startswith('func move_npc('):
        lines.insert(i + 1, '\tif not is_instance_valid(npc): return\n')
        break

for i, line in enumerate(lines):
    if 'while is_moving:' in line:
        lines.insert(i + 1, '\t\tif not is_instance_valid(target_npc):\n\t\t\tbreak\n')
        break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Updated npc_choreography.gd")
