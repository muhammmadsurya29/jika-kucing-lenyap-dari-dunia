extends CanvasLayer

@onready var objective_label = $MarginContainer/PanelContainer/VBoxContainer/ObjectiveText

func _ready() -> void:
	# Sembunyikan jika kosong
	if objective_label.text == "":
		visible = false

func set_objective(text: String) -> void:
	if objective_label:
		objective_label.text = text
		visible = (text != "")
