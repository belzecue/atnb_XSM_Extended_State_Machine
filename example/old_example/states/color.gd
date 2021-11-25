tool
extends State


# FUNCTIONS AVAILABLE TO INHERIT
#func _on_enter(_args):
#	pass

func _on_update(_delta) -> void:
	var prev_pressed = Input.is_action_just_pressed("prev_color")
	var next_pressed = Input.is_action_just_pressed("next_color")
	if prev_pressed or next_pressed:
		get_active_substate().who_was_i()


func _after_update(_delta) -> void:
	var prev_pressed = Input.is_action_just_pressed("prev_color")
	var next_pressed = Input.is_action_just_pressed("next_color")
	if prev_pressed or next_pressed:
		print("Now I am ", get_active_substate().name)
