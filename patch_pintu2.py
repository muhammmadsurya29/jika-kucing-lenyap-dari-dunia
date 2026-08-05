import sys

filepath = 'scenes/maps/kamar_mc.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

target = 'locked_timeline_per_hari = Array[String](["", "hari1_pintu", "", "", ""])'
replacement = 'locked_timeline_per_hari = Array[String](["", "hari1_pintu", "", "", "hari4_belum_beres"])'

if target in content:
    content = content.replace(target, replacement)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Successfully patched PintuKeluar locked_timeline_per_hari.")
else:
    print("Target string not found in kamar_mc.tscn.")
