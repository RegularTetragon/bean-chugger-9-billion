extends CharacterBody3D

var linear_velocity : Vector3
var angular_velocity : Vector3
var sleeping = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


@rpc("unreliable", "authority", "call_remote", 1)
func sync_physics(transform: Transform3D):
	self.transform = transform

@rpc("reliable", "authority")
func sync_free():
	queue_free()
