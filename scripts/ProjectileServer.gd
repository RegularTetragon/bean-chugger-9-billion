extends RigidBody3D

var despawn_time = 10
const sync_time = 1/30
var sync_timer = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(do_damage)
	pass # Replace with function body.

func do_damage(body: PhysicsBody3D):
	if body.has_method("damage"):
		body.damage(5)
		sync_free.rpc()
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	despawn_time -= delta
	if despawn_time <= 0:
		sync_free.rpc()
		queue_free()
	if !sleeping and sync_timer <= 0:
		sync_physics.rpc(transform)
		sync_timer = sync_time
	sync_timer -= delta
	

@rpc("unreliable", "authority", "call_remote", 1)
func sync_physics(transform: Transform3D):
	pass

@rpc("reliable", "authority")
func sync_free():
	pass
