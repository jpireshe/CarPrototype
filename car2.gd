extends CharacterBody3D

class_name PlayerCar

######### CAR IMPLEMENTATION

# tire angle
const MaxTireAngleRad: float = 1
const MinTireAngleRad: float = -1

# turning tires
var TurnIntensity: float = 3
var NormalizeIntensity: float = TurnIntensity / 4
const TireRadius: float = 1.8

# acceleration, break and slow
var Acceleration: float = 15
const BreakIntensity: float = 20
const SlowIntensity: float = BreakIntensity / 2

var MaxSpeed: float = 30.0
var MinSpeed: float = -30.0

# varies
var Speed: float = 0.0
var CarAngleRad: float = 0.0
var TireAngleRad: float = 0.0
var Lights: bool = false
var IsBreakingAction: bool = false
var BackLightEnergyIntensity: float = 3
var BreakLightEnergyIntensity: float = 6

@export var TireLeftFront: Node3D
@export var TireRightFront: Node3D
@export var TireLeftBack: Node3D
@export var TireRightBack: Node3D

@export var LightFrontRight: SpotLight3D
@export var LightFrontLeft: SpotLight3D

@export var LightBackRight: OmniLight3D
@export var LightBackLeft: OmniLight3D

func _ready() -> void:
	rotate(basis.y, CarAngleRad)
	CarAngleRad = rotation.y

func RotateCar(delta: float) -> void:
	if TireAngleRad == 0: return
	
	var toRotate = TireAngleRad * delta
	if Speed < 0: toRotate *= -1
	
	CarAngleRad += toRotate
	rotate(basis.y, toRotate)

func TurnTiresFront(_delta: float) -> void:	
	var wheels = [TireLeftFront, TireRightFront] 
		
	for wheel: Node3D in wheels:
		wheel.rotation.y = TireAngleRad / 2
		
func RotateTires(delta: float) -> void:	
	var wheels = [TireLeftFront, TireRightFront, TireRightBack]
	
	for wheel: Node3D in wheels:
		wheel.rotate_object_local(Vector3(1, 0, 0), delta * (Speed / TireRadius))
		
	TireLeftBack.rotate_object_local(Vector3(-1, 0, 0), delta * (Speed / TireRadius))
	
func Accelerate(delta: float) -> void:
	if Speed >= MaxSpeed: return
	
	# change speed positively
	var accelerate: float = Acceleration * delta
	Speed += accelerate
	if Speed > MaxSpeed: Speed = MaxSpeed
		
func Reverse(delta: float) -> void:
	if Speed <= MinSpeed: return
	
	# change speed negatively past zero
	var accelerate: float = Acceleration * delta
	Speed -= accelerate
	if Speed < MinSpeed: Speed = MinSpeed
	
func Break(delta: float) -> void:
	if Speed == 0: return
	
	# change speed negatively until zero
	var toBreak: float = BreakIntensity * delta
	
	if Speed > 0:
		Speed -= toBreak
		if Speed < 0: Speed = 0
		return
	
	Speed += toBreak
	if Speed > 0: Speed = 0
	
func SlowDown(delta: float) -> void:
	if Speed == 0: return
	
	var toSlow: float = SlowIntensity * delta
	
	if Speed > 0:
		Speed -= toSlow
		if Speed < 0: Speed = 0
		return
	
	Speed += toSlow
	if Speed > 0: Speed = 0
	
func TurnLeft(delta: float) -> void:
	if TireAngleRad >= MaxTireAngleRad: return
	
	var toTurn: float = TurnIntensity * delta	
	TireAngleRad += toTurn
	if TireAngleRad > MaxTireAngleRad: TireAngleRad = MaxTireAngleRad
			
func TurnRight(delta: float) -> void:
	if TireAngleRad <= MinTireAngleRad: return
	
	var toTurn: float = TurnIntensity * delta
	TireAngleRad -= toTurn
	if TireAngleRad < MinTireAngleRad: TireAngleRad = MinTireAngleRad
	
func TurnNormal(delta: float) -> void:
	if TireAngleRad == 0: return
	
	var toNormalize: float = NormalizeIntensity * delta
	
	if TireAngleRad > 0:
		TireAngleRad -= toNormalize
		if TireAngleRad < 0: TireAngleRad = 0
		
		return
	
	TireAngleRad += toNormalize
	if TireAngleRad > 0: TireAngleRad = 0
	
func UseGravity(delta: float) -> bool:
	if not is_on_floor():
		velocity += get_gravity() * delta
		return false
	
	velocity.y = 0
	return true
	
func _physics_process(delta: float) -> void:	
	# input polling - for events that can happen as long as the
	# user holds them
	
	# accelerate vs break vs none
	IsBreakingAction = false
	if Input.is_action_pressed("Accelerate"): 
		if Speed >= 0: Accelerate(delta)
		else: Break(delta)
	elif Input.is_action_pressed("Break"):
		IsBreakingAction = true 
		if Speed > 0: Break(delta)
		else: Reverse(delta)
	else: 
		SlowDown(delta) 
	
	# turn left, right or none
	if Input.is_action_pressed("TurnLeft"): 
		TurnLeft(delta)
	elif Input.is_action_pressed("TurnRight"):
		TurnRight(delta)
	else:
		TurnNormal(delta)
	
	# processing what happens w input
	if IsBreakingAction:
		TurnBackLights(true)
		BackLightEnergy(BreakLightEnergyIntensity)
	else: 
		TurnBackLights(Lights)
		BackLightEnergy(BackLightEnergyIntensity)
	
	if Speed != 0:
		RotateTires(delta)
		RotateCar(delta)
	TurnTiresFront(delta)
	
	if UseGravity(delta):
		# set velocity
		velocity.x = sin(CarAngleRad) * Speed
		velocity.z = cos(CarAngleRad) * Speed
	
	move_and_slide()

func _input(event):
	# input signaling - for events that happen once (i.e. turning lights on)
	if event.is_action_pressed("ToggleLights"):
		ToggleLights()

func ToggleLights():
	Lights = !Lights
	
	LightFrontRight.visible = true if Lights else false
	LightFrontLeft.visible = LightFrontRight.visible
	
	TurnBackLights(true if Lights or IsBreakingAction else false)
	BackLightEnergy(BackLightEnergyIntensity if !IsBreakingAction else BreakLightEnergyIntensity)
	
func TurnBackLights(IsVisible: bool):
	LightBackRight.visible = IsVisible
	LightBackLeft.visible = IsVisible
	
func BackLightEnergy(energy: float):
	LightBackRight.light_energy = energy
	LightBackLeft.light_energy = energy
