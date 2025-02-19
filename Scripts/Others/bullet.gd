extends Area3D

@export var speed := 30.0
@export var damage := 100.0
@export var target_group := "Enemy"
var direction := Vector3.ZERO

func _ready():
	#connecting signal
	body_entered.connect(_on_body_entered)
	#DEBUG SHIT
	print("Projectile direction: ", direction)
	print("Projectile speed: ", speed)
	print("Target group: ", target_group)

func _physics_process(delta):
	position += direction * speed * delta
	
func _on_body_entered(body):
	if body.is_in_group(target_group):
		body.take_damage(damage)
		#DEBUG STATEMENT
		print("Hit", body.name, "for", damage, " damage")
	queue_free()
