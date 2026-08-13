extends Node

var player: AudioStreamPlayer
var current_track: String = ""
var _bgm_tween: Tween

const TRACKS = {
	"main_menu": "res://assets/audio/BGM_MAIN_MENU.mp3",
	"all": "res://assets/audio/BGM_ALL.ogg",
	"mantan": "res://assets/audio/BGM_MANTAN.ogg",
	"album": "res://assets/audio/BGM_ALBUM.ogg",
	"credit": "res://assets/audio/BGM_CREDIT.ogg",
	"prolog": "res://assets/audio/BGM_PROLOG.ogg"
}

const VOLUMES = {
	"all": -15.0, # BGM_ALL dikecilkan volumenya
	"mantan": -15.0,
	"album": -15.0,
	"prolog": -10.0
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = AudioStreamPlayer.new()
	player.bus = "Master"
	add_child(player)
	
	get_tree().scene_changed.connect(_on_scene_changed)
	
	# Hook into Dialogic timeline start if possible to detect scenes
	if Dialogic.has_signal("timeline_started"):
		Dialogic.timeline_started.connect(_on_timeline_started)
		
	# Hook into Dialogic signal events to catch specific moments (like mantan leaving)
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	# Panggil secara manual untuk scene pertama (seperti Main Menu) yang sudah dimuat
	if get_tree().current_scene:
		_on_scene_changed(get_tree().current_scene)

func _on_scene_changed(new_scene: Node) -> void:
	if not new_scene.scene_file_path:
		return
	var path = new_scene.scene_file_path
	
	if path.contains("main_menu"):
		play_track("main_menu")
	elif path.contains("credit"):
		play_track("credit")
	elif path.contains("prolog"):
		stop_track()
	elif path.contains("scenes/maps/"):
		if current_track != "album" and current_track != "mantan":
			play_track("all")

func _on_timeline_started() -> void:
	if Dialogic.current_timeline != null:
		var tl = Dialogic.current_timeline.resource_path.get_file()
		if tl.contains("mantan") or tl.contains("cafe") or tl.contains("taman") or tl.contains("tsutaya") or tl.contains("bioskop_luar"):
			play_track("mantan")
		elif tl.contains("album") or tl.contains("hari3_malam_kamar"):
			play_track("album")
		elif tl.contains("hari0_malam_aloha"):
			play_track("prolog")
		elif tl.contains("hari0_bangun") or tl.contains("prolog_vonis") or tl.contains("hari0_flashback"):
			stop_track()
		else:
			# Jangan ubah jika sudah benar
			if not (current_track in ["mantan", "album", "credit"]):
				play_track("all")

func _on_dialogic_signal(argument: String) -> void:
	# Jika mantan pamit pergi, kembalikan BGM ke normal
	if argument == "mantan_pergi" or argument == "alt2_mantan_pergi":
		play_track("all")

func play_track(track_name: String, fade_duration: float = 1.0) -> void:
	if current_track == track_name and player.playing:
		return
		
	if not TRACKS.has(track_name):
		return
		
	current_track = track_name
	var stream = load(TRACKS[track_name])
	
	# Aktifkan looping secara otomatis dari kode
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = true
		
	var target_vol = VOLUMES.get(track_name, 0.0)
	
	if _bgm_tween and _bgm_tween.is_valid():
		_bgm_tween.kill()
		
	_bgm_tween = create_tween()
	
	if player.playing:
		_bgm_tween.tween_property(player, "volume_db", -40.0, fade_duration / 2.0)
		_bgm_tween.tween_callback(func():
			player.stream = stream
			player.play()
		)
		_bgm_tween.tween_property(player, "volume_db", target_vol, fade_duration / 2.0)
	else:
		player.volume_db = target_vol
		player.stream = stream
		player.play()

func stop_track(fade_duration: float = 1.0) -> void:
	current_track = ""
	
	if _bgm_tween and _bgm_tween.is_valid():
		_bgm_tween.kill()
		
	if player.playing:
		_bgm_tween = create_tween()
		_bgm_tween.tween_property(player, "volume_db", -40.0, fade_duration)
		_bgm_tween.tween_callback(player.stop)
