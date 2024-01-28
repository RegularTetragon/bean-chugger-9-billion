extends Node
class_name  PlayerLocal
@export var local_character_prefab : PackedScene
var character : Node3D
var peer_id : int
var client : NetworkClient

@rpc("authority", "reliable")
func spawn_character():
	character = local_character_prefab.instantiate()
	character.player = self
	character.name = "Character" + str(peer_id)
	client.get_node("World").add_child(character)
