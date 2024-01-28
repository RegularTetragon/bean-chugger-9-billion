extends CharacterBody3D

var player : PlayerServer
var xrot : float
var yrot : float
var shooting = false
var shot_timer = 0
var health = 100

const shot_time = 0.05
@export var prefab_bean : PackedScene

func _ready():
	$ThirdPerson/AnimationPlayer.play("Idleloop")

func _process(delta):
	if shooting:
		shot_timer -= delta
		if shot_timer <= 0:
			shot_timer = shot_time
			var angle = randf() * TAU
			var radius = randf() * 0.5
			var dir = (Vector3(radius * cos(angle), radius * sin(angle), -10)
					.rotated(Vector3.RIGHT, yrot)
					.rotated(Vector3.UP, xrot)
					.normalized())
			player.server.spawn_projectile(global_position + Vector3.UP * 1 + dir, 
				dir*50)
			shoot_sound.rpc()
	if global_position.y <= -100:
		damage(1000000)
	
@rpc("unreliable_ordered", "call_remote", "any_peer")
func sync_move(global_position, animation, xrot, yrot):
	if multiplayer.get_remote_sender_id() == player.peer_id:
		self.global_position = global_position
		self.xrot = xrot
		self.yrot = yrot
		self.rotation = Vector3(0, self.xrot, 0)
		sync_move.rpc(global_position, animation, xrot, yrot)

@rpc("reliable", "authority")
func sync_health(health):
	pass


@rpc("reliable", "any_peer")
func begin_shoot():
	shooting = true
	if multiplayer.get_remote_sender_id() == player.peer_id:
		begin_shoot.rpc()

@rpc("reliable", "any_peer")
func end_shoot():
	shooting = false
	if multiplayer.get_remote_sender_id() == player.peer_id:
		end_shoot.rpc()

@rpc("unreliable", "authority")
func shoot_sound():
	pass

func damage(amount):
	print(amount, health)
	health -= amount
	sync_health.rpc(health)
	if health <= 0:
		sync_died.rpc()
		queue_free()

@rpc("reliable", "authority")		
func sync_died():
	pass #queue_free()
