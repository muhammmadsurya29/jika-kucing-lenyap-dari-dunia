import os

filepath = 'scripts/cutscene_jalan.gd'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

setup_logic = '''	if StoryManager.current_day == 100:
		if StoryManager.alt2_post_bioskop:
			_setup_post_bioskop()
		else:
			_setup_day100()
	elif StoryManager.is_ending_c:
		if StoryManager.ending_c_state == "luar_bioskop":
			_setup_ending_c_luar()
		elif StoryManager.ending_c_state == "luar_bioskop_post":
			_setup_ending_c_post()
	else:
		_setup_normal()
'''

# Find the if block in _ready
for i, line in enumerate(lines):
    if line.strip() == 'if StoryManager.current_day == 100:':
        # delete lines until end of function
        del lines[i:i+6]
        lines.insert(i, setup_logic)
        break

new_funcs = '''
func _setup_ending_c_luar():
	is_walking = false
	var pintu = bioskop.get_node_or_null("NodeDepanPintuBioskop")
	
	player.position.x = target_x - 10
	player.position.y = bioskop.position.y + 40
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("idle_up")
		
	if pintu:
		mantan.position = bioskop.position + pintu.position
	else:
		mantan.position.x = target_x
		mantan.position.y = bioskop.position.y
	mantan.hide() # Akan muncul dari pintu
	
	if not Dialogic.current_timeline:
		Dialogic.start("ending_c_bioskop_luar")

func _setup_ending_c_post():
	is_walking = false
	player.position.x = target_x - 10
	player.position.y = bioskop.position.y + 40
	mantan.position.x = target_x + 20
	mantan.position.y = bioskop.position.y + 40
	
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("idle_right")
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("idle_left")
		
	if not Dialogic.current_timeline:
		Dialogic.start("ending_c_bioskop_luar_post")
'''

lines.extend(new_funcs.splitlines(True))

# Add signal handlers
signal_logic = '''	elif argument == "ending_c_mantan_keluar":
		_ending_c_mantan_keluar()
	elif argument == "ending_c_duduk":
		_ending_c_duduk()
'''

for i, line in enumerate(lines):
    if line.strip() == 'elif argument == "alt2_mantan_pergi":':
        lines.insert(i + 2, signal_logic)
        break

funcs_2 = '''
func _ending_c_mantan_keluar():
	mantan.show()
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("walk_down")
	var tween = create_tween()
	tween.tween_property(mantan, "position:y", mantan.position.y + 40, 1.5)
	await tween.finished
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("idle_left")
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("idle_right")

func _ending_c_duduk():
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("sit_down")
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("sit_down")
'''
lines.extend(funcs_2.splitlines(True))

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Updated cutscene_jalan.gd")
