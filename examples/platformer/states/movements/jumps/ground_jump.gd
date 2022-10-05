tool
extends State


var tween
export (int) var ground_jump_speed = 250


# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(_args) -> void:
	# Commented because it is defined in the inspector as "Anim_on_enter"
	# play("Jump")

	# This tween is to have the jump preparation appear still on ground
	# tweek the values according to your sprite size, and jump speed
	var anim_player = get_node_or_null(animation_player)
	if anim_player:
		var anim_length = anim_player.current_animation_length
		tween = get_tree().create_tween()
		tween.tween_property(target.skin, "position:y", 14.0, anim_length)


func jump():
	target.velocity.y = - ground_jump_speed


func _on_exit(_args) -> void:
	tween.stop()

