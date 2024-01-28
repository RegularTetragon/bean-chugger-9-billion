extends CharacterBody3D

var player : PlayerServer
var xrot : float
var yrot : float
var shooting = false
var shot_timer = 0
const shot_time = 0.1
@export var prefab_bean : PackedScene

func _ready():
	$ThirdPerson/AnimationPlayer.play("Idleloop")

func _process(delta):
	if shooting:
		shot_timer -= delta
		if shot_timer <= 0:
			shot_timer = shot_time
			shoot_bean(global_position + Vector3.UP * 1, 
				Vector3(0, 0, -50)
					.rotated(Vector3.RIGHT, yrot)
					.rotated(Vector3.UP, xrot))
	
@rpc("unreliable_ordered", "call_remote", "any_peer")
func sync_move(global_position, animation, xrot, yrot):
	if multiplayer.get_remote_sender_id() == player.peer_id:
		self.global_position = global_position
		self.xrot = xrot
		self.yrot = yrot
		self.rotation = Vector3(0, self.xrot, 0)
		sync_move.rpc(global_position, animation, xrot, yrot)


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

func shoot_bean(position, velocity):
	var bean = prefab_bean.instantiate()
	bean.name = "Projectile" + str(bean.get_instance_id())
	player.server.get_node("World/Projectiles").add_child(bean)
	bean.global_position = position
	bean.linear_velocity = velocity

	s2c_shoot_bean.rpc(bean.get_instance_id(), position, velocity)

@rpc("reliable", "authority")
func s2c_shoot_bean(position, velocity):
	pass
