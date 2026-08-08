@tool
extends DialogicLayoutLayer

@export var portrait_size_mode: DialogicNode_PortraitContainer.SizeModes = DialogicNode_PortraitContainer.SizeModes.FIT_SCALE_HEIGHT
@export var portrait_origin_anchor: DialogicNode_PortraitContainer.OriginAnchors = DialogicNode_PortraitContainer.OriginAnchors.BOTTOM_CENTER
@export var portrait_origin_offset := Vector2(0, 0)

func _apply_export_overrides() -> void:
	var container: DialogicNode_PortraitContainer = $DialogicNode_PortraitContainer
	if container:
		container.size_mode = portrait_size_mode
		container.origin_anchor = portrait_origin_anchor
		container.origin_offset = portrait_origin_offset
		if container.has_method("update_portrait_transforms"):
			container.update_portrait_transforms()
