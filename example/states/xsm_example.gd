tool
extends State


# FUNCTIONS TO INHERIT #
func _on_update(_delta) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
