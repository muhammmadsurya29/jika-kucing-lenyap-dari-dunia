import os

filepath = 'scripts/bioskop_cutscene.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    leading_spaces = len(line) - len(line.lstrip(' \t'))
    if leading_spaces > 0:
        s = line[:leading_spaces]
        tabs = s.count('\t') + s.count(' ') // 4
        new_lines.append('\t' * tabs + line.lstrip(' \t'))
    else:
        new_lines.append(line)

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print("Fixed indentation in bioskop_cutscene.gd")
