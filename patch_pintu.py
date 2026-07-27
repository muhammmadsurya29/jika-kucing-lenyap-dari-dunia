import sys

filepath = 'scenes/maps/jalanan_kota.tscn'

append_str = '''
[node name="PintuPemakaman" type="Area2D" parent="." unique_id=500000012]
position = Vector2(-300, -365)
script = ExtResource("2_svcpl")
target_scene = "res://scenes/maps/kantor_pemakaman.tscn"
minimum_day_to_exit = 0
inactive_on_days = Array[int]([0, 1, 2, 3, 99, 100, 101])
marker_icon = ExtResource("13_l77tl")
icon_hframes = 18
icon_vframes = 8
icon_frame = 10
use_offscreen_pointer = true
pointer_texture = ExtResource("13_l77tl")
pointer_hframes = 18
pointer_vframes = 16
pointer_scale = Vector2(5, 5)
pointer_margin = 200.0
frame_right = 90
frame_left = 91
frame_top_right = 92
frame_top_left = 93

[node name="CollisionShape2D" type="CollisionShape2D" parent="PintuPemakaman" unique_id=500000013]
position = Vector2(1, 0)
shape = SubResource("RectangleShape2D_1s67d")
'''

with open(filepath, 'a', encoding='utf-8') as f:
    f.write(append_str)

print("Successfully appended PintuPemakaman to jalanan_kota.tscn")
