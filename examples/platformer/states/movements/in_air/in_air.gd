tool
extends State


# FUNCTIONS TO INHERIT #
func _on_update(delta):
	if target.is_on_floor():
		var _s = change_state("OnGround")
		return
	if target.is_on_wall():
		print("onwall")
		var _s = change_state("OnWall")
		return		

	if target.dir != 0:
		target.velocity.x = lerp(target.velocity.x, target.air_speed * target.dir, target.acceleration * delta)

	if target.dir == 0:
		target.velocity.x = lerp(target.velocity.x,  0, target.air_friction * delta)
		if abs(target.velocity.x) < target.walk_margin: 
			target.velocity.x = 0

	var skin = target.get_node("Skin")
	skin.rotation = - target.velocity.angle_to(Vector2.UP)


func _on_exit(_args) -> void:
	target.get_node("Skin").rotation = 0
