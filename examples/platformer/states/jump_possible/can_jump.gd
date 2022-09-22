tool
extends State


# FUNCTIONS AVAILABLE TO INHERIT
func _on_enter(_args) -> void:
	if has_timer("PreJump"):
		choose_jump()


func _on_update(_delta) -> void:
	if has_timer("PreJump") or Input.is_action_just_pressed("jump"):
		choose_jump()


func choose_jump():
	if is_active("OnWall"):
		change_state("WallJump")
	else:
		change_state("GroundJump")


func _on_CanPreJump_pre_jumped():
	var _t = add_timer("PreJump", target.prejump_time)
