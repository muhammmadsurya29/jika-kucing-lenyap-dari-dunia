import os

filepath = 'scenes/maps/kamar_mc.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_node = '''
[node name="TriggerDapurDay101" type="Area2D" parent="."]
position = Vector2(7, 13)
script = ExtResource("15_d8i2l")

[node name="CollisionShape2D" type="CollisionShape2D" parent="TriggerDapurDay101"]
position = Vector2(73.375, 101)
shape = SubResource("RectangleShape2D_d8i2l")
'''

for i, line in enumerate(lines):
    if line.startswith('[node name="TriggerDapur" type="Area2D"'):
        lines.insert(i, new_node)
        break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Injected TriggerDapurDay101 into kamar_mc.tscn")
