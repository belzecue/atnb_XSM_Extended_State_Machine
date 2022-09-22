tool
extends State


# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(_args) -> void:
	play("Jump")

	# This tween is to have the jump preparation appear still on ground
	# tweek the values according to your sprite size, and jump speed
	var anim_length = anim_player.current_animation_length
	var skin = target.get_node("Skin")
	var tween = get_tree().create_tween()
	tween.tween_property(skin, "position:y", 14.0, anim_length)

	var _t = get_parent().add_timer("JumpTimer", target.jump_time)


func jump():
	target.velocity.y = - target.jump_speed


func _on_exit(_args):
	target.get_node("Skin").position.y = 0
	
