extends CharacterBody3D

# tire angle
const MaxTireAngleRad: float = 0.7
const MinTireAngleRad: float = -0.7

# turning tires
const TurnIntensity: float = 3
const NormalizeIntensity: float = TurnIntensity / 2

# acceleration, break and slow
const Acceleration: float = 15
const BreakIntensity: float = 50
const SlowIntensity: float = BreakIntensity / 2

const MaxSpeed: float = 100.0
const MinSpeed: float = -100.0

# varies
var Speed: float = 0.0
var CarAngleRad: float = 2.0
var TireAngleRad: float = 0.0

func _ready() -> void:
	rotate(basis.y, CarAngleRad)

func RotateCar(delta: float) -> void:
	if TireAngleRad == 0: return
	
	var toRotate = TireAngleRad * delta
	CarAngleRad += toRotate
	rotate(basis.y, toRotate)

@export var TireLeftFront: CSGCylinder3D
@export var TireRightFront: CSGCylinder3D
@export var TireLeftBack: CSGCylinder3D
@export var TireRightBack: CSGCylinder3D

func TurnTires(delta: float) -> void:	
	var wheels = [TireLeftFront, TireRightFront]
	
	for wheel: CSGCylinder3D in wheels:
		var toRotate 
		if Speed >= 0: toRotate = TireAngleRad - wheel.rotation.y
		else: toRotate = -1 *TireAngleRad - wheel.rotation.y
		
		if toRotate == 0: continue
		
		wheel.rotate(basis.y, toRotate)
		
func RotateTires(delta: float) -> void:	
	var wheels = [TireLeftFront, TireRightFront, TireLeftBack, TireRightBack]
	
	for wheel: CSGCylinder3D in wheels:
		wheel.rotate_object_local(Vector3(0, -1, 0), delta * (Speed / TireLeftBack.radius))
	
func Accelerate(delta: float) -> void:
	# change speed positively
	var accelerate: float = Acceleration * delta
	
	if Speed < MaxSpeed:
		Speed += accelerate
		if Speed > MaxSpeed: Speed = MaxSpeed
		
func Reverse(delta: float) -> void:
	# change speed negatively past zero
	var accelerate: float = Acceleration * delta
	
	if Speed > MinSpeed:
		Speed -= accelerate
		if Speed < MinSpeed: Speed = MinSpeed
	
func Break(delta: float) -> void:
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
	var toTurn: float = TurnIntensity * delta
	if TireAngleRad < 0: TireAngleRad = 0
	
	if TireAngleRad < MaxTireAngleRad:
		TireAngleRad += toTurn
		if TireAngleRad > MaxTireAngleRad: TireAngleRad = MaxTireAngleRad
			
func TurnRight(delta: float) -> void:
	var toTurn: float = TurnIntensity * delta
	
	if TireAngleRad > 0: TireAngleRad = 0
	
	if TireAngleRad > MinTireAngleRad:
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
	
func UseGravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		return
	
	velocity.y = 0
	
func Jump() -> void:
	if not is_on_floor(): return
	velocity.y = 5
	
func _physics_process(delta: float) -> void:
	UseGravity(delta)
	if not is_on_floor(): return
	
	if Input.is_action_pressed("Accelerate"): 
		if Speed >= 0: Accelerate(delta)
		else: Break(delta)
		
	elif Input.is_action_pressed("Break"): 
		if Speed > 0: Break(delta)
		else: Reverse(delta)
			
	else: 
		SlowDown(delta) 
		
	if Input.is_action_pressed("TurnLeft"): 
		if Speed > 0: TurnLeft(delta)
		else: TurnRight(delta)
		
	elif Input.is_action_pressed("TurnRight"):
		if Speed > 0: TurnRight(delta)
		else: TurnLeft(delta)
		
	else:
		TurnNormal(delta)
		
	if Input.is_action_pressed("Jump"):
		Jump()
	
	# set velocity
	velocity.x = sin(CarAngleRad) * Speed
	velocity.z = cos(CarAngleRad) * Speed
	
	# show we do know the speed
	print("VELOCITY: ", velocity, " | SPEED: ", Speed)
	
	if Speed != 0:
		RotateTires(delta)
		RotateCar(delta)
	
	TurnTires(delta)

	move_and_slide()
