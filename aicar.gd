extends PlayerCar

class_name AICar
@export var CurrentCheckpoint: Checkpoint	

var actionTimer: Timer
func _ready() -> void:
	rotate(basis.y, CarAngleRad)
	CarAngleRad = rotation.y
	MaxSpeed = 15
	MinSpeed = -15
	
	actionTimer = Timer.new()
	actionTimer.wait_time = 0.1
	actionTimer.one_shot = true
	add_child(actionTimer)
	actionTimer.timeout.connect(_on_action_timer_timeout)
	actionTimer.start()
		
func _input(event):
	return

func GetDirectionToCheckpoint():
	var forward_direction: Vector3 = -transform.basis.z
	forward_direction = forward_direction.rotated(Vector3.UP, TireAngleRad)
	
	var direction_to_target: Vector3 = (CurrentCheckpoint.position - position).normalized()
	
	var cross_product = forward_direction.cross(direction_to_target)
	
	return cross_product.y

enum TurnState {
	RIGHT,
	LEFT,
	NORMAL
}
var turnState: TurnState
func Turn():
	var DirectionToGo: float = GetDirectionToCheckpoint()
	
	if DirectionToGo > 0:
		turnState = TurnState.RIGHT

	elif DirectionToGo < 0:
		turnState = TurnState.LEFT
		
	else: 
		turnState = TurnState.NORMAL


var time_to_change_state: bool = true
func _on_action_timer_timeout():
	time_to_change_state = true
	
enum AccelerateState {
	ACCELERATE,
	BREAK,
	STALL
}

var accelerateState: AccelerateState
func ChangeAccelerateState():
	time_to_change_state = false
	accelerateState = GetNextAccelerateState()
	
	IsBreakingAction = false
	
	if accelerateState == AccelerateState.BREAK:
		IsBreakingAction = true
	actionTimer.start()
		
	# handle lights	
	if IsBreakingAction:
		TurnBackLights(true)
		BackLightEnergy(BreakLightEnergyIntensity)
	else: 
		TurnBackLights(Lights)
		BackLightEnergy(BackLightEnergyIntensity)

func GetNextAccelerateState() -> AccelerateState:
	if Speed <= 3:
		return AccelerateState.ACCELERATE
		
	if TireAngleRad <= MinTireAngleRad / 3 and turnState == TurnState.RIGHT:
		return AccelerateState.BREAK

	elif TireAngleRad >= MaxTireAngleRad / 3 and turnState == TurnState.LEFT:
		return AccelerateState.BREAK
		
	return AccelerateState.ACCELERATE
	
func ChangeState():
	# accelerateState
	ChangeAccelerateState()
			
func _physics_process(delta: float) -> void:
	# turn
	Turn()
	if turnState == TurnState.RIGHT:
		TurnRight(delta)
	elif turnState == TurnState.LEFT:
		TurnLeft(delta)
	else: 
		TurnNormal(delta)
	
	if time_to_change_state:
		ChangeState()
			
	# accelerate
	if accelerateState == AccelerateState.ACCELERATE:
		Accelerate(delta)
	elif accelerateState == AccelerateState.BREAK:
		Break(delta)
	else: 
		SlowDown(delta) 
	
	# animation
	if Speed != 0:
		RotateTires(delta)
		RotateCar(delta)
	TurnTiresFront(delta)
	
	# move
	if UseGravity(delta):
		# set velocity
		velocity.x = sin(CarAngleRad) * Speed
		velocity.z = cos(CarAngleRad) * Speed
		
	move_and_slide()


func ChangeCheckpoint(next: Checkpoint) -> void:
	if next != CurrentCheckpoint.NextMileMarker: return
	CurrentCheckpoint = next
