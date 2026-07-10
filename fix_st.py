import os

filepath = 'scripts/story_trigger.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if 'if target_day == 101 and self.name == "TriggerDapur":' in line:
        lines[i] = '\t\tif target_day == 101 and self.name == "TriggerDapurDay101":\n'
        break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Updated story_trigger.gd for TriggerDapurDay101")
