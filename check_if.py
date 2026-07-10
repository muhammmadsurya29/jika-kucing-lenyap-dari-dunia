import os

filepath = 'scripts/cutscene_jalan.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if line.strip().endswith(':'):
        # find next non-empty line
        j = i + 1
        while j < len(lines) and lines[j].strip() == '':
            j += 1
        if j < len(lines):
            next_line = lines[j]
            # check indent
            curr_indent = len(line.replace('\t', '    ')) - len(line.replace('\t', '    ').lstrip(' '))
            next_indent = len(next_line.replace('\t', '    ')) - len(next_line.replace('\t', '    ').lstrip(' '))
            if next_indent <= curr_indent:
                print(f"Possible error at line {i+1}:\n{line.rstrip()}\n{next_line.rstrip()}")
