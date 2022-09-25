tool
extends State


# FUNCTIONS TO INHERIT #
func _on_update(_delta):
	if target.velocity.y < 0 and abs(target.velocity.y) < target.jump_top_margin:
		var _st = change_state("FallTop")

	if Input.is_action_just_pressed("jump") && get_node_or_null("CoyoteTime") != null:
		var _st = change_state("Jump")
	elif Input.is_action_just_pressed("jump"):
		var _t = add_timer("PreJump",target.prejump_time)


# Called from the track method call in AnimationPlayer, anim "FallTop"
func _on_top_curve_finished():
	var _st = change_state("Top2Fall")


# Called from the track method call in AnimationPlayer, anim "FallTop"
func _on_top2fall_finished():
	#Change to itself (ie "Fall" here)
	var _st = change_state()
