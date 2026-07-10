import os

filepath = 'scripts/cutscene_jalan.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    leading_spaces = len(line) - len(line.lstrip(' \t'))
    # convert all leading whitespace to tabs
    if leading_spaces > 0:
        # replace leading sequence of tabs/spaces with just tabs
        # count how many indent levels
        s = line[:leading_spaces]
        # assume each \t is 1 level, each 4 spaces is 1 level
        tabs = s.count('\t') + s.count(' ') // 4
        new_lines.append('\t' * tabs + line.lstrip(' \t'))
    else:
        new_lines.append(line)

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print("Fixed indentation in cutscene_jalan.gd")
