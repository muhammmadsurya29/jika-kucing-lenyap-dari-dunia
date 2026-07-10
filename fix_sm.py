import os

filepath = 'scripts/story_manager.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_logic = '''
		var choreo = get_tree().get_root().find_child("NPCChoreography", true, false)
		if choreo:
			choreo.queue_free()
'''

for i, line in enumerate(lines):
    if 'elif argument == "fade_kubis":' in line:
        # insert new logic right after is_kubis_lenyap = true
        lines.insert(i + 2, new_logic)
        break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Updated story_manager.gd")
