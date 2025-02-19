extends CharacterBody3D

@export var health := 100.0
@export var projectile_scene: PackedScene = preload("res://Scenes/bullet.tscn")
@export var shoot_interval := 2.0

@onready var raycast := $RayCast3D
@onready var shoot_timer := $ShootTimer
@onready var player = get_tree().get_first_node_in_group("PlayerCharacter")

func _ready():
	if not player:
		#IF YOU SEE THIS MESSAGE KILL YOURSELF
		push_error("You did it wrong.")
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()

func _on_shoot_timer_timeout():
	if can_see_player():
		var projectile = projectile_scene.instantiate()
		projectile.global_position = $Muzzle.global_position
		projectile.set("direction", (player.global_position - global_position).normalized())
		projectile.set("target_group", "Player")
		get_parent().add_child(projectile)

func can_see_player() -> bool:
	#raycast check
	if not is_instance_valid(player):
		return false
	
	#point raycast at player (convert player POS to raycast local space)
	var player_pos_local = raycast.to_local(player.global_position)
	raycast.target_position = player_pos_local
	
	#force an update
	raycast.force_raycast_update()
	
	#check if it hwit
	if raycast.is_colliding():
		return raycast.get_collider() == player
	return false
	

func take_damage(amount):
	health -= amount
	#DEBUG
	print("Enemy took damage! Health remaining: ", health)
	if health <= 0:
		print("Enemy died FUCK YEAH!!!!")
		queue_free()
		
