tool
extends State


# FUNCTIONS TO INHERIT #
func _on_enter(_args):
	if target.velocity.y >= 0: play("Fall")
	else: play("FlyUp")
	if state_root.was_state_active("Walk"):
		print("Fall from Walk")
	if state_root.was_state_active("Jump"):
		print("Fall from Jump")


func _on_update(_delta):
	if target.is_on_floor() && get_node_or_null("PreJump") != null:
		var _s = change_state("Jump")
		return
	if target.is_on_floor():
		var _s = change_state("Land")
		return

	if target.velocity.y < 0 && target.velocity.y > -200 && !is_playing("TopCurve"):
		play("TopCurve")

	if Input.is_action_just_pressed("jump") && get_node_or_null("CoyoteTime") != null:
		var _s = change_state("Jump")
	elif Input.is_action_just_pressed("jump"):
		var _t = add_timer("PreJump",target.prejump_time)


# Called from the track method call in AnimationPlayer, anim "Fall"
func _on_top_curve_finished():
	play("Fall")
