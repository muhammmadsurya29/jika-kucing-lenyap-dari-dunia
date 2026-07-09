import re

with open('scripts/story_manager.gd', 'r', encoding='utf-8') as f:
    content = f.read()

# We need to extract the part starting from `elif argument == "alt_malam_terakhir_selesai":`
# up to right before `func play_alt_sore_kamar() -> void:`
pattern = r'(?s)(^\s*elif argument == "alt_malam_terakhir_selesai":.*?(?=^\s*func play_alt_sore_kamar))'
match = re.search(pattern, content, re.MULTILINE)
if match:
    extracted = match.group(1)
    
    # Remove the extracted part from the original content
    content = content.replace(extracted, "")
    
    # Now we need to insert the extracted part right before `func _on_dialogue_started() -> void:`
    insert_target = 'func _on_dialogue_started() -> void:'
    if insert_target in content:
        content = content.replace(insert_target, extracted + "\n" + insert_target)
        
        with open('scripts/story_manager.gd', 'w', encoding='utf-8') as f:
            f.write(content)
        print("Successfully fixed story_manager.gd")
    else:
        print("Could not find insertion target.")
else:
    print("Could not find extraction target.")
