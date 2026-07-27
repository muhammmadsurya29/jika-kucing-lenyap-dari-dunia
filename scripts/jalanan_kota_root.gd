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
			
	if StoryManager.current_day == 4 and "beres_beres" in StoryManager.day4_state:
		# Buat area pintu pemakaman
		var area = Area2D.new()
		area.position = Vector2(-350, -354) # Di sebelah kiri MC
		var coll = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(150, 150)
		coll.shape = shape
		area.add_child(coll)
		add_child(area)
		
		var SceneTransition = load("res://scripts/scene_transition.gd")
		if SceneTransition:
			area.set_script(SceneTransition)
			area.target_scene = "res://scenes/maps/kantor_pemakaman.tscn"
			area.body_entered.connect(area._on_body_entered)
			
		# Tambahkan UI petunjuk
		var label = Label.new()
		label.text = "⬅ Ke Kantor Pemakaman"
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color.YELLOW)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 4)
		label.position = Vector2(-480, -420)
		add_child(label)
