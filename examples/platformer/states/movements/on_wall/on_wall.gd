tool
extends State


# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(_args) -> void:
	var _st = change_state("CanJump")

	var skin = target.get_node("Skin")
	target.wall_dir = 1
	skin.position.y = - 2
	skin.scale.x = -1
	if target.get_slide_count() > 0:
		var collision = target.get_slide_collision(0)
		if collision.normal.dot(Vector2.RIGHT) > 0:
			target.wall_dir = - 1

	skin.position.x = - target.wall_dir * 4
	skin.rotation = - target.wall_dir * PI/2


func _on_update(_delta) -> void:
	target.velocity.y = 0


func _on_landed_on_wall():
	var _st = change_state("IdleOnWall")


func _on_exit(_args) -> void:
	var skin = target.get_node("Skin")
	skin.rotation = 0
	skin.position = Vector2()
	skin.scale.x = 1