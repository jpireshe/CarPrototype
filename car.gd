extends CharacterBody3D

const GRAVITY = 9.8

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
