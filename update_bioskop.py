import os

filepath = 'scripts/bioskop_cutscene.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_logic = '''
	elif StoryManager.current_day == 101:
		if not Dialogic.current_timeline:
			Dialogic.start("ending_c_dalam_bioskop")
'''

for i, line in enumerate(lines):
    if 'if StoryManager.current_day == 100:' in line:
        lines.insert(i, new_logic)
        break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Updated bioskop_cutscene.gd")
