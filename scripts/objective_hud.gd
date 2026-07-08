extends CanvasLayer

@onready var objective_label = $MarginContainer/PanelContainer/VBoxContainer/ObjectiveText
var is_dialog_active: bool = false

func _ready() -> void:
	# Sembunyikan jika kosong
	if objective_label.text == "":
		visible = false

func set_objective(text: String) -> void:
	if objective_label:
		objective_label.text = text
		if not is_dialog_active:
			visible = (text != "")

func hide_hud() -> void:
	is_dialog_active = true
	visible = false

func show_hud() -> void:
	is_dialog_active = false
	if objective_label and objective_label.text != "":
		visible = true
