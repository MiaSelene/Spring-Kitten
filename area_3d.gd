extends Area3D
@export var win_popup: Control

func _ready() -> void:
	win_popup.visible = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		win_popup.visible = true
		print("win")
		get_tree().paused = true
