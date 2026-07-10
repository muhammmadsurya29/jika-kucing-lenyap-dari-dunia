import os

filepath = 'scripts/story_trigger.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_logic = '''		
		if target_day == 101 and self.name == "TriggerDapur":
			Dialogic.start("ending_c_pagi_dapur")
			return
'''

for i, line in enumerate(lines):
    if 'if target_day < timeline_per_hari.size():' in line:
        lines.insert(i, new_logic)
        break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Updated story_trigger.gd")
