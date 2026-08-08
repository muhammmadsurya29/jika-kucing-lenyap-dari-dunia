extends Node

func play_map(timeline: Variant, label: Variant = "") -> Node:
	if Dialogic.Styles.has_method("change_style"):
		Dialogic.Styles.change_style("dialog_npc")
	if label != "":
		return Dialogic.start(timeline, label)
	return Dialogic.start(timeline)

func play_vn(timeline: Variant, label: Variant = "") -> Node:
	if Dialogic.Styles.has_method("change_style"):
		Dialogic.Styles.change_style("dialog_potrait")
	if label != "":
		return Dialogic.start(timeline, label)
	return Dialogic.start(timeline)
