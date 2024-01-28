extends Node
class_name  PlayerServer
const respawn_time = 5;
var respawn_timer = respawn_time
@export var server_character_prefab : PackedScene
var character : Node3D
var server : NetworkServer
var peer_id : int
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_character()


@rpc("authority", "reliable")
func spawn_character():
	character = server_character_prefab.instantiate()
	character.name = "Character" + str(peer_id)
	character.player = self
	server.get_node("World").add_child(character)
	spawn_character.rpc()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_instance_valid(character):
		respawn_timer -= delta
	if respawn_timer < 0:
		spawn_character()
		respawn_timer = respawn_time
