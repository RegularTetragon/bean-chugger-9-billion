extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var xrot = 0
var yrot = 0
var player : PlayerLocal
var health = 100
@export var prefab_bean : PackedScene
func _ready():
	$FirstPerson.make_current()



func _input(event):
	if event is InputEventMouseMotion:
		var mouse_diff = event.relative / 100
		xrot -= mouse_diff.x
		yrot -= mouse_diff.y
		yrot = clamp(yrot, -PI/2, PI/2)
		rotation = Vector3(0, xrot, 0)
		$FirstPerson.rotation = Vector3(yrot, 0, 0)
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
		begin_shoot.rpc_id(1)
	if Input.is_action_just_released("fire"):
		end_shoot.rpc_id(1)
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
func sync_died():
	var sound = $DiedSound
	remove_child(sound)
	player.client.current_level.add_child(sound)
	sound.global_position = global_position
	sound.play()
	queue_free()
	
@rpc("unreliable", "authority")
func shoot_sound():
	$ShootSound.play()

@rpc("reliable", "authority")
func sync_health(health):
	self.health = health
