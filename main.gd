extends Node3D

var CurrentCheckpoint: Checkpoint = null
func _ready():
	CurrentCheckpoint = get_node("Checkpoints/Checkpoint")
	CurrentAICheckpoint = get_node("Checkpoints/Checkpoint")

func _on_checkpoint_next_check_point(next: Checkpoint) -> void:
	if not next:
		print("ERROR: No next for this checkpoint")
		return
	
	if next != CurrentCheckpoint.NextMileMarker:
		return
	
	next.TurnOn()
	if CurrentCheckpoint.IsFirstCheckpoint: 
		NewLap()
	CurrentCheckpoint = next
	
var Lap: int = 0
func NewLap() -> void:
	Lap += 1
	$UI/Lap.text = "LAP: " + str(Lap)

var AILap: int = 0
func NewAILap() -> void:
	AILap += 1
	$UI/AILap.text = "AI LAP: " + str(AILap)

@export var aiCar: AICar
var CurrentAICheckpoint: Checkpoint = null
func _on_checkpoint_next_ai_checkpoint(next: Checkpoint) -> void:
	if not next:
		print("ERROR: No next for this checkpoint")
		return
		
	aiCar.ChangeCheckpoint(next)
	if CurrentAICheckpoint.IsFirstCheckpoint: 
		NewAILap()
	CurrentAICheckpoint = next 
		
	
