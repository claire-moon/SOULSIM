extends Node

#grapple hook shit
@export var ray: RayCast3D
@export var rope: Node3D
@export var g_cross: TextureRect
@export var g_ray: RayCast3D
@export var camera: Camera3D
@export var lerp_speed: float = 2.0

@export var minScale: float = 0.05
@export var maxScale: float = 0.3
@export var maxDistance: float = 60

@export var rest_length = 2.0
@export var stiffness = 10.0
@export var damping = 1.0 

@onready var player: PlayerCharacter = get_parent()

var target: Vector3
var launched = false
var target_screen_position: Vector2 = Vector2.ZERO

func _ready():
	if g_ray == null:
		print("G_RAY NOT ASSIGNED!")
	else:
		print("G_RAY READY!")
		
	if g_cross == null:
		print("G_CROSS NOT ASSIGNED!")
	else:
		print("C_CROSS READY!")
		
	#INIT TARGET SCREEN POS INIT
	target_screen_position = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("grapple"):
		launch()
	if Input.is_action_just_released("grapple"):
		retract()

	if launched:
		handle_grapple(delta)
	
	update_rope()
	update_crosshair(delta)

func launch():
	if ray.is_colliding():
		target = ray.get_collision_point()
		launched = true
	
func retract():
	launched = false
	
func handle_grapple(delta: float):
	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target)
	
	var displacement = target_dist - rest_length
	
	var force = Vector3.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude
		
		var vel_dot = player.velocity.dot(target_dir)
		var damping = -damping * vel_dot * target_dir
		
		force = spring_force + damping
	
	player.velocity += force * delta
	
func update_rope():
	if !launched:
		rope.visible = false
		return
		
	rope.visible = true
	
	var dist = player.global_position.distance_to(target)
	
	rope.look_at(target)
	rope.scale = Vector3(1, 1, dist)
	
func update_crosshair(delta: float):
	if g_ray == null or g_cross == null or camera == null:
		return
		
	#determining target screen pos
	var screen_position: Vector2
	
	if g_ray.is_colliding():
		#get collision point
		var target_point = g_ray.get_collision_point()
		
		#convert 3D point to 2D screen x,y
		screen_position = camera.unproject_position(target_point)
		screen_position.x = clamp(screen_position.x, 0, get_viewport().size.x)
		screen_position.y = clamp(screen_position.y, 0, get_viewport().size.y)
		
		#scale crosshair based on distance
		var distance = g_ray.global_position.distance_to(target_point)
		var normalized_distance = clamp(distance / maxDistance, 0.0, 1.0)
		g_cross.scale = Vector2(lerp(maxScale, minScale, normalized_distance), lerp(maxScale, minScale, normalized_distance))
		
		#turn the preview crosshair on
		g_cross.visible = true
		
		#DEBUG STATEMENTS
		#print("VIEWPORT SIZE: ", get_viewport().size)
		#print("G_CROSS POS: ", g_cross.position)
		#print("G_CROSS DIS: ", distance)
		#print("NORM DIS: ", normalized_distance)
		#print("G_CROSS SCL: ", g_cross.scale)
		#print("G_CROSS VIS: ", g_cross.visible)
	else:
		screen_position = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)
		g_cross.visible = false
		#print("G_CROSS NOT RENDERED")
		
	#update interpolation
	target_screen_position = target_screen_position.lerp(screen_position, lerp_speed * delta)
	
	#update crosshair
	g_cross.position = target_screen_position - g_cross.size / 2
	g_cross.size = Vector2(32, 32)
		
		
