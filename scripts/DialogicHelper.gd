extends Node

var styles_cleared = false

func _clear_character_styles_once():
	if styles_cleared: return
	styles_cleared = true
	var char_dict = DialogicResourceUtil.get_character_directory()
	for char_id in char_dict.keys():
		if char_id == "narator": continue
		var char_res = DialogicResourceUtil.get_character_resource(char_id)
		if char_res and char_res.custom_info.has("style"):
			char_res.custom_info.erase("style")

func play_map(timeline: Variant, label: Variant = "") -> Node:
	_clear_character_styles_once()
	if Dialogic.Styles.has_method("change_style"):
		Dialogic.Styles.change_style("dialog_npc")
	if label != "":
		return Dialogic.start(timeline, label)
	return Dialogic.start(timeline)

func play_vn(timeline: Variant, label: Variant = "") -> Node:
	_clear_character_styles_once()
	if Dialogic.Styles.has_method("change_style"):
		Dialogic.Styles.change_style("dialog_potrait")
	if label != "":
		return Dialogic.start(timeline, label)
	return Dialogic.start(timeline)

