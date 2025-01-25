extends CharacterBody2D

# Speed of the character
var speed = 200
# Gravity force
var gravity = 500
# Jump force
var jump_strength = -300
# Max fall speed
var max_fall_speed = 300

# Squish animation variables
var squish_factor = 0.0
var squish_velocity = 0.0
var squish_duration = 0.2 # Duration of squish animation (in seconds)
var squish_triggered = false # Ensure squish happens only once per landing

# References
@onready var animated_sprite = $AnimatedSprite2D # Reference to AnimatedSprite2D
@onready var shader_material = $AnimatedSprite2D.material # Reference to the shader material

func _ready():
	# Play idle animation by default when the game starts
	animated_sprite.play("idle")

func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed

	# Horizontal movement
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		if animated_sprite.animation != "walk": # Play walk animation if moving
			animated_sprite.play("walk")
		animated_sprite.flip_h = false # Face right
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
		animated_sprite.flip_h = true # Face left
	else:
		velocity.x = 0
		if is_on_floor() and animated_sprite.animation != "idle":
			animated_sprite.play("idle") # Play idle animation when stationary

	# Jump
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = jump_strength
		squish_triggered = false # Reset squish trigger when jumping
		animated_sprite.play("jump") # Play jump animation

	# Trigger squish when landing
	if is_on_floor() and velocity.y >= 0 and !squish_triggered:
		squish_factor = 1.0 # Start fully squished
		squish_velocity = -1.0 / squish_duration # Set pop-up speed
		squish_triggered = true # Ensure squish is triggered only once
		animated_sprite.play("land") # Play landing animation
		print("Squish triggered") # Log only once

	# Animate squish factor
	if squish_factor > 0.0:
		squish_factor += squish_velocity * delta
		if squish_factor < 0.0:
			squish_factor = 0.0 # Clamp to 0

	# Move the character
	move_and_slide()

	# Update shader parameters
	if shader_material and shader_material.shader:
		shader_material.set("shader_param/velocity", velocity)
		shader_material.set("shader_param/squish_factor", squish_factor)
