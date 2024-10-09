extends Area3D
class_name Checkpoint

@export var NextMileMarker: Checkpoint
@export var IsFirstCheckpoint: bool

func _ready() -> void:
	if IsFirstCheckpoint: TurnOn()
	else: TurnOff()
	
func _on_body_entered(body: Node3D) -> void:
	if(body is AICar):
		HandleAICarEnter()
		return
		
	if(body is PlayerCar):
		HandlePlayerCarEnter()
		return

signal next_check_point(next: Checkpoint)
func HandlePlayerCarEnter():
	emit_signal("next_check_point", NextMileMarker)
	TurnOff()

signal next_ai_checkpoint(next: Checkpoint)
func HandleAICarEnter():
	emit_signal("next_ai_checkpoint", NextMileMarker)

func TurnOn() -> void:
	visible = true

func TurnOff() -> void:
	visible = false
