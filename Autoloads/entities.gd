extends Node


enum SpawnableEntities {
	ZOMBIE,
}

var SpawnableEntityScenes = {
	Entities.SpawnableEntities.ZOMBIE: preload("res://Scenes/Enemies/Zombie/zombie.tscn")
}
