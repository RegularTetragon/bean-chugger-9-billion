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
	$ThirdPerson/AnimationPlayer.play(animation)


@rpc("reliable", "call_remote")
func begin_shoot():
	pass

@rpc("reliable", "call_remote")
func end_shoot():
	pass

@rpc("reliable", "authority")		
func sync_died():
	queue_free()

@rpc("reliable", "authority")
func sync_health(health):
	pass
