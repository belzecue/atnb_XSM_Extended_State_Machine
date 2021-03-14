tool
extends State


# FUNCTIONS TO INHERIT #
func _on_update(delta):
	if target.dir != 0:
		target.velocity.x = lerp(target.velocity.x, target.air_speed * target.dir, target.acceleration * delta)
	if target.dir == 0:
		target.velocity.x = lerp(target.velocity.x,  0, target.air_friction * delta)
		if abs(target.velocity.x) < target.walk_margin: target.velocity.x = 0
