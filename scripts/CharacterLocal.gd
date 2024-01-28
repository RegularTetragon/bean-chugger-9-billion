extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_last : Vector2

var xrot = 0
var yrot = 0
var player : PlayerLocal
@export var prefab_bean : PackedScene
func _ready():
	mouse_last = get_viewport().get_mouse_position()
	$FirstPerson.make_current()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	var mouse_current = get_viewport().get_mouse_position()
	var mouse_diff = mouse_current - mouse_last
	mouse_last = mouse_current
	xrot -= mouse_diff.x * .01
	yrot -= mouse_diff.y * .01
	yrot = clamp(yrot, -PI/4, PI/4)
	rotation = Vector3(0, xrot, 0)
	$FirstPerson.rotation = Vector3(yrot, 0, 0)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if Input.is_action_just_pressed("fire"):
		begin_shoot.rpc()
	if Input.is_action_just_released("fire"):
		end_shoot.rpc()
	move_and_slide()
	sync_move.rpc_id(1, global_position, "Runloop" if input_dir.length() > 0.1 else "Idleloop", xrot, yrot)

@rpc("unreliable_ordered", "call_remote", "any_peer")
func sync_move(global_position, animation, xrot, yrot):
	pass

@rpc("reliable", "call_local")
func begin_shoot():
	pass

@rpc("reliable", "call_local")
func end_shoot():
	pass

@rpc("reliable", "authority")
func s2c_shoot_bean(bean_id, position, velocity):
	var bean = prefab_bean.instantiate()
	bean.name = "Projectile" + str(bean_id)
	player.client.get_node("World/Projectiles").add_child(bean)
	bean.global_position = position
	bean.linear_velocity = velocity

	s2c_shoot_bean.rpc(position, velocity)
