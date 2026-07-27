extends Node2D

func _ready() -> void:
	if StoryManager.is_night:
		var night_mod = CanvasModulate.new()
		night_mod.color = Color("262a42")
		add_child(night_mod)
		
	# Tunggu scene transition selesai
	await get_tree().create_timer(1.0).timeout
	
	if StoryManager.current_day == 101:
		if not Dialogic.current_timeline:
			Dialogic.start("ending_c_jalanan")

