tool
extends StateLoop


func _on_update(_delta) -> void:
	var prev_pressed = Input.is_action_just_pressed("prev_color")
	var next_pressed = Input.is_action_just_pressed("next_color")
	if prev_pressed:
		# get_active_substate().who_was_i()
		prev_in_loop()
	elif next_pressed:
		# get_active_substate().who_was_i()
		next_in_loop()
