extends CharacterBody3D



# How fast the player moves in meters per second.
@export var speed = 1
# How quickly the kitchen loses aim in percent of speed variance per second
@export var clumsiness = 0.5
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 1

var jump_trajectory = Vector3.ZERO
var view = Vector3(0, 0, -1)
var magnitude = 0
var time_since_starting_aim = 0
var just_jumped = false
var started_aim = false



func _physics_process(delta):
	# We create a local variable to store the input direction.
	# We check for each move input and update the direction accordingly.
	if is_on_floor() and Input.is_action_pressed("Charge Jump"):
		magnitude += speed*delta 
		started_aim = true
	if is_on_floor() and Input.is_action_pressed("Ease Jump"):
		magnitude -= speed*delta 
	if is_on_floor() and Input.is_action_pressed("Rotate Left"):
		view = view.rotated( Vector3(0, 1, 0), delta*speed)
	if is_on_floor() and Input.is_action_pressed("Rotate Right"):
		view = view.rotated( Vector3(0, 1, 0), -speed*delta)
	if is_on_floor() and Input.is_action_pressed("Release Jump"):
		self.velocity = velocitiy(magnitude)
		just_jumped = true
		time_since_starting_aim = 0
		started_aim = false
	elif is_on_floor():
		self.velocity *= clumsiness / 100
		if just_jumped:
			$"lower bound".mesh.clear_surfaces()
			$"upper bound".mesh.clear_surfaces()
			just_jumped = false
			magnitude = 0
	if not is_on_floor():
		self.velocity.y -= fall_acceleration*delta
	move_and_slide()
	$Pivot.basis = Basis.looking_at(view)
	if started_aim:
		time_since_starting_aim += delta
		show_possible_trajectories(time_since_starting_aim)
	
	
func show_possible_trajectories(time_since_starting_aim):
	_draw_trajectory($"lower bound", 0)
	
func velocitiy(magnitude):
	var angle = (view.normalized()*1.5 + Vector3(0, max(1,magnitude/2), 0)).normalized()
	var strength = (magnitude)
	return angle * strength


func variance(time_since_starting_aim):
	return speed * time_since_starting_aim * clumsiness / 100 * 0 # DISABLING THIS FOR NOW TODO
	
func _draw_trajectory(target, variance):
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1, 0, 0) # Red

	
	target.position = self.position
	var immediate_mesh = target.mesh
	target.material_override = material
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	var velocity = velocitiy(magnitude)
	var time_step = 0.1
	var t = 0.0
	var pos = Vector3.ZERO

	for i in 200:
		var next_t = t + time_step
		var next_pos = _get_projectile_point(velocity, next_t)
		immediate_mesh.surface_add_vertex(pos)
		immediate_mesh.surface_add_vertex(next_pos)
		pos = next_pos
		t = next_t
	immediate_mesh.surface_end()
		 


func _get_projectile_point(velocity: Vector3, t: float) -> Vector3:
	# Simple projectile motion
	return velocity * t - 0.5 * Vector3(0, fall_acceleration, 0) * t * t
