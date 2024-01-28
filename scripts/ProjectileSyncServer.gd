extends Node3D
class_name ProjectileSyncServer
@export var projectile_prefab : PackedScene 

func spawn_projectile(position, velocity):
	var bean = projectile_prefab.instantiate()
	bean.name = "Projectile" + str(bean.get_instance_id())
	add_child(bean)
	bean.global_position = position
	bean.linear_velocity = velocity

func _process(delta):
	s2c_sync_projectiles.rpc(get_children().map(func(child): return child.transform))
	
@rpc("authority", "unreliable_ordered")
func s2c_sync_projectiles(projectiles):
	pass
