extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var color_rect = $ColorRect

func _ready() -> void:
	color_rect.visible = false

func transition_to(scene_path: String, duration: float = 0.5) -> void:
	color_rect.visible = true
	# Animasi kita secara default panjangnya 1 detik.
	# Speed scale = 1.0 / duration. Jika duration 0.5, speed_scale = 2.0 (lebih cepat)
	if duration <= 0:
		duration = 0.1
	animation_player.speed_scale = 1.0 / duration
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file(scene_path)
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	color_rect.visible = false
