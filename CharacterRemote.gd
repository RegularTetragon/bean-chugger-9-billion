extends CharacterBody3D
var xrot : float
var yrot : float
var player : PlayerRemote
@export var prefab_bean : PackedScene
func _ready():
	$ThirdPerson/AnimationPlayer.play("Idleloop")
	
@rpc("unreliable_ordered", "call_remote", "authority")
func sync_move(global_position, animation, xrot, yrot):
	self.global_position = global_position
	self.xrot = xrot
	self.yrot = yrot
	self.rotation = Vector3(0, self.xrot, 0)
	$AnimationTree.set("parameters/XLook/seek_request", 2 * (yrot + PI/2) / PI)
	$AnimationTree.set("parameters/Transition/transition_request", animation)


@rpc("reliable", "call_remote")
func begin_shoot():
	pass

@rpc("reliable", "call_remote")
func end_shoot():
	pass

@rpc("unreliable", "authority")
func shoot_sound():
	$ShootSound.play()

@rpc("reliable", "authority")		
func sync_died():
	queue_free()

@rpc("reliable", "authority")
func sync_health(health):

	var time = 2 * (1 - float(health) / 100)
	print("health", health, "time", time)
	$AnimationTree.set("parameters/Bloat/seek_request", time)
