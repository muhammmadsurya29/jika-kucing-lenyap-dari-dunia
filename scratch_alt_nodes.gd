@tool
extends EditorScript

func _run():
	print("Menjalankan script untuk menambah Kotak Pos dan Bangku Biru...")

	# 1. Jalanan Kota
	var jalanan_scene = load("res://scenes/maps/jalanan_kota.tscn")
	if jalanan_scene:
		var jalanan = jalanan_scene.instantiate()
		var mailbox = Area2D.new()
		mailbox.name = "KotakPos"
		mailbox.set_script(load("res://scripts/interactable.gd"))
		mailbox.set("timeline_name", "alt_mengantar_surat")
		mailbox.set("required_day", 99)
		mailbox.position = Vector2(500, 500) # Posisi default tengah
		
		var col = CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var shape = RectangleShape2D.new()
		shape.size = Vector2(60, 60)
		col.shape = shape
		mailbox.add_child(col)
		
		jalanan.add_child(mailbox)
		mailbox.owner = jalanan
		col.owner = jalanan
		
		var pack = PackedScene.new()
		pack.pack(jalanan)
		ResourceSaver.save(pack, "res://scenes/maps/jalanan_kota.tscn")
		print("Kotak Pos berhasil ditambahkan ke jalanan_kota.tscn!")

	# 2. Taman Bukit
	var taman_scene = load("res://scenes/maps/Taman_Bukit.tscn")
	if taman_scene:
		var taman = taman_scene.instantiate()
		var bench = Area2D.new()
		bench.name = "BangkuBiru"
		bench.set_script(load("res://scripts/interactable.gd"))
		bench.set("timeline_name", "alt_taman_bukit")
		bench.set("required_day", 99)
		bench.position = Vector2(300, 300) # Posisi default
		
		var col2 = CollisionShape2D.new()
		col2.name = "CollisionShape2D"
		var shape2 = RectangleShape2D.new()
		shape2.size = Vector2(60, 60)
		col2.shape = shape2
		bench.add_child(col2)
		
		taman.add_child(bench)
		bench.owner = taman
		col2.owner = taman
		
		var pack2 = PackedScene.new()
		pack2.pack(taman)
		ResourceSaver.save(pack2, "res://scenes/maps/Taman_Bukit.tscn")
		print("Bangku Biru berhasil ditambahkan ke Taman_Bukit.tscn!")
