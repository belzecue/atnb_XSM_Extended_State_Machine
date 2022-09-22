tool
extends State


# FUNCTIONS TO INHERIT #
func _on_update(_delta):
	# var skin = target.get_node("Skin")
	# skin.rotation = - target.velocity.angle_to(Vector2.UP)
	# if target.dir == 0:
	# 	if skin.flip_h:
	# 		skin.rotation -=  PI/2
	# 	else:
	# 		skin.rotation +=  PI/2

	if target.is_on_floor():
		var _s = change_state("Land")
	elif target.velocity.y < 0 && target.velocity.y > -200 && !is_playing("TopCurve"):
		play("TopCurve")

	if Input.is_action_just_pressed("jump") && get_node_or_null("CoyoteTime") != null:
		var _s = change_state("Jump")
	elif Input.is_action_just_pressed("jump"):
		var _t = add_timer("PreJump",target.prejump_time)


# Called from the track method call in AnimationPlayer, anim "Fall"
func _on_top_curve_finished():
	play("Fall")


# func _on_exit(_args) -> void:
# 	target.get_node("Skin").rotation = 0
