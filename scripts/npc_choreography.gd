extends Node

@export var target_npc: Node2D
@export var point_a: Marker2D
@export var point_b: Marker2D
@export var point_c: Marker2D
@export var point_d: Marker2D
@export var movement_speed: float = 60.0
@export var auto_start_loop: bool = true

var is_moving: bool = false

func _ready() -> void:
	# Dengarkan sinyal dari Dialogic
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	if auto_start_loop:
		# Tunggu sebentar agar scene selesai dimuat
		await get_tree().create_timer(1.0).timeout
		start_choreography()

func _on_dialogic_signal(argument: String) -> void:
	if argument == "mulai_koreografi":
		start_choreography()

func start_choreography() -> void:
	if is_moving or not target_npc: return
	is_moving = true
	
	var anim = target_npc.get_node_or_null("AnimatedSprite2D")
	
	while is_moving:
		# Gerak dari posisi awal (A) ke B
		if point_a: target_npc.global_position = point_a.global_position
		if point_b:
			await move_npc(target_npc, anim, point_b.global_position, "walk_down")
			
		# Gerak dari B ke C
		if point_c:
			await move_npc(target_npc, anim, point_c.global_position, "walk_right")
			
		# Gerak dari C ke D
		if point_d:
			await move_npc(target_npc, anim, point_d.global_position, "walk_down")
			
		# Diam sebentar
		if anim: anim.play("idle_down")
		await get_tree().create_timer(1.5).timeout
		
		# Kembali (D ke C)
		if point_c:
			await move_npc(target_npc, anim, point_c.global_position, "walk_up")
			
		# Kembali (C ke B)
		if point_b:
			await move_npc(target_npc, anim, point_b.global_position, "walk_left")
			
		# Kembali (B ke A)
		if point_a:
			await move_npc(target_npc, anim, point_a.global_position, "walk_up")
			
		# Selesai satu putaran
		if anim: anim.play("idle_down")
		
		# Beritahu Dialogic bahwa gerakan selesai (jika ada yang menunggu)
		Dialogic.VAR.set("koreografi_selesai", true)
		
		if not auto_start_loop:
			break
			
	is_moving = false

func move_npc(npc: Node2D, anim: AnimatedSprite2D, target_pos: Vector2, anim_name: String) -> void:
	if anim: anim.play(anim_name)
	var dist = npc.global_position.distance_to(target_pos)
	var time = dist / movement_speed
	
	var tween = get_tree().create_tween()
	tween.tween_property(npc, "global_position", target_pos, time)
	await tween.finished
