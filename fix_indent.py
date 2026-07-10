import os

filepath = 'scripts/npc_choreography.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    leading_spaces = len(line) - len(line.lstrip(' '))
    if leading_spaces > 0:
        tabs = leading_spaces // 4
        new_lines.append('\t' * tabs + line.lstrip(' '))
    else:
        new_lines.append(line)

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print("Fixed indentation in npc_choreography.gd")
