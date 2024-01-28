extends Node3D
@export var projectile_prefab : PackedScene 

func spawn_projectile():
	var bean = projectile_prefab.instantiate()
	add_child(bean)
	
@rpc("authority", "unreliable_ordered")
func s2c_sync_projectiles(projectiles):
	var projecile_difference = get_children().size() - projectiles.size()
	if projecile_difference > 0:
		for i in range(projecile_difference):
			get_child(i).queue_free()
	elif projecile_difference < 0:
		for i in range(-projecile_difference):
			spawn_projectile()
	for i in range(projectiles.size()):
		get_child(i).transform = projectiles[i]
