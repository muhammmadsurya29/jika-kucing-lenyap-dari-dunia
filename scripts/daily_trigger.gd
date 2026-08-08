extends Node

@export var timelines_per_hari: Array[String] = []

func _ready() -> void:
	# Tunggu sebentar agar scene transition selesai
	await get_tree().create_timer(0.5).timeout
	
	var current_day = StoryManager.current_day
	
	if current_day == 100:
		if not Dialogic.current_timeline:
			DialogicHelper.play_vn("alt2_pagi_kamar")

	elif current_day == 101:
		if not Dialogic.current_timeline:
			DialogicHelper.play_vn("ending_c_pagi_bangun")
	elif current_day < timelines_per_hari.size():
		var timeline_to_play = timelines_per_hari[current_day]
		if timeline_to_play != "" and not Dialogic.current_timeline:
			DialogicHelper.play_vn(timeline_to_play)
