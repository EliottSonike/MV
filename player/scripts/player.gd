class_name Player extends CharacterBody2D


#region ///  on ready variables
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_stand: CollisionShape2D = $CollisionStand
@onready var collision_crouch: CollisionShape2D = $CollisionCrouch
@onready var one_way_plat_rc: RayCast2D = $OneWayPlatRC
@onready var one_way_plat_rc_2: RayCast2D = $OneWayPlatRC2
@onready var one_way_plat_rc_3: RayCast2D = $OneWayPlatRC3
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#endregion

#region ///  export variables
@export var move_speed : float = 150
@export var jump_velocity : float = 400
@export var max_fall_velocity : float = 600
#endregion

#region /// state Machine Variables
var states : Array[ PlayerState ]
var current_state : PlayerState : 
	get : return states.front()
var previous_state : PlayerState : 
	get : return states[ 1 ]
#endregion

#region /// Standard Variables
var direction : Vector2 = Vector2.ZERO
var gravity : float = 980
var gravity_multiplier : float = 1.0
@export var idle: Node
@export var run: Node
#endregion

func _ready() -> void:
	intialize_states()
	pass

func is_on_one_way() -> bool:
	for rc in [one_way_plat_rc, one_way_plat_rc_2, one_way_plat_rc_3]:
		if rc.is_colliding():
			return true
	return false
	
func _unhandled_input(event: InputEvent) -> void:
	change_state( current_state.handle_input(event))
	
func _process(delta: float) -> void:
	update_direction()
	change_state(current_state.process(delta))
	pass


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta * gravity_multiplier
	velocity.y = clampf(velocity.y,-1000,max_fall_velocity)
	move_and_slide()
	change_state(current_state.physics_process(delta))
	pass
	
func intialize_states() -> void:
	states = []
	for c in $States.get_children():
		if c is PlayerState :
			states.append(c)
			c.player = self
		pass
	if states.size() == 0 :
		return
	
	for state in states:
		state.init()
		
	change_state (current_state)
	current_state.enter()
	pass


func change_state( new_state : PlayerState ) -> void:
	if new_state == null:
		return
	elif new_state == current_state : 
		return
		
	if current_state:
		current_state.exit()
	
	states.push_front (new_state)
	current_state.enter()
	states.resize(3)
	$Label.text = current_state.name
	pass

func update_direction()-> void:
	var prev_direction : Vector2 = direction
	
	var x_axis = Input.get_axis("left","right")
	var y_axis = Input.get_axis("up","down")
	
	direction = Vector2(x_axis,y_axis)
	
	if prev_direction.x != direction.x :
		if direction.x < 0 :
			sprite.flip_h = true
		elif direction.x > 0 :
			sprite.flip_h = false
	pass
