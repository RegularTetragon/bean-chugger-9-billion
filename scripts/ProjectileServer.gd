extends RigidBody3D

var despawn_time = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(do_damage)
	await get_tree().create_timer(despawn_time).timeout
	queue_free()

func do_damage(body: PhysicsBody3D):
	if body.has_method("damage"):
		body.damage(5)
		queue_free()
