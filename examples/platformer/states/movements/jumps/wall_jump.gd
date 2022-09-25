tool
extends State


# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(_args) -> void:
	# This tween is to have the jump preparation appear still on wall
	# tweek the values according to your sprite size, and jump speed
	var anim_length = anim_player.current_animation_length
	var skin = target.get_node("Skin")
	var tween = get_tree().create_tween()
	tween.tween_property(skin, "position:y", 10.0, anim_length)
	tween.parallel().tween_property(skin, "position:x", target.wall_dir * 10.0, anim_length)

	skin.rotation = - target.wall_dir * PI/2

	var _t = get_parent().add_timer("JumpTimer", target.jump_time)


func jump():
	target.velocity = Vector2(- target.wall_dir * target.jump_speed, - target.jump_speed)
	target.velocity = target.velocity.normalized() * target.jump_speed
	

func _on_exit(_args) -> void:
	var skin = target.get_node("Skin")
	skin.rotation = 0
