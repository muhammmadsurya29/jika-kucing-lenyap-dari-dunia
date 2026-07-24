import sys

filepath = 'scenes/maps/jalan_malam_cutscene.tscn'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

old_str = 'NodeDepanPintuBioskop'
new_str = 'NodeDepanBioskopHari1'

if old_str in content:
    content = content.replace(old_str, new_str)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Successfully patched jalan_malam_cutscene.tscn")
else:
    print("Could not find the target string in jalan_malam_cutscene.tscn")
