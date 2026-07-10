import os

filepath = 'scripts/daily_trigger.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_logic = '''
	elif current_day == 101:
		if not Dialogic.current_timeline:
			Dialogic.start("ending_c_pagi_bangun")
'''

for i, line in enumerate(lines):
    if 'elif current_day < timelines_per_hari.size():' in line:
        lines.insert(i, new_logic)
        break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Updated daily_trigger.gd")
