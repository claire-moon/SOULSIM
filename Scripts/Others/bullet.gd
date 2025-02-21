extends RigidBody3D

@export var speed = 10.0

func _ready():
	pass # Replace with function body.

func _process(delta):
	var collision = move_and_collide(-transform.basis.z * delta * speed)
	if collision:
		var body = collision.get_collider()
		if body.is_in_group("CanBeShotKilled"):
			print("It's a hit!")
			body.queue_free()
			queue_free()
			
		if body.is_in_group("ShootableSurface"):
			print("Shot a wall! Dingus!")
			queue_free()
			
func _on_hit_area_3d_body_entered(body):
	if body.is_in_group("CanBeShotKilled"):
		print("It's a hit!")
		body.queue_free()
		queue_free()
		
	if body.is_in_group("ShootableSurface"):
		print("Shot a wall! Dingus!")
		queue_free()

func _on_timer_timeout():
	queue_free()
	print("Bullet timed out.")
