extends Area2D

@onready var sprite = $AnimatedSprite2D

const WALK_SPEED = 100
const RUN_SPEED = 200
const RUSH_SPEED = 300

var velocity = Vector2.ZERO
var is_jumping = false
var is_auto_running = false
var auto_run_speed = 0
var auto_run_animation = "idle"
var direction = Vector2.ZERO
var is_dead = false
var is_dying = false
var is_damaging = false  # <--- dagdag para sa damage lock

func _ready():
	pass

func _physics_process(delta):
	if is_dead:
		return

	handle_input(delta)
	handle_movement(delta)
	handle_animation()

func handle_input(delta):
	if is_dying:
		return

	if Input.is_action_just_pressed("move-damage"):
		damage()
	
	if Input.is_action_just_pressed("move-die"):
		death()
	
	if Input.is_action_just_pressed("move-run"):
		is_auto_running = !is_auto_running
		auto_run_speed = RUN_SPEED if is_auto_running else WALK_SPEED
		auto_run_animation = "run" if is_auto_running else "idle"

	if Input.is_action_just_pressed("move-rush"):
		is_auto_running = !is_auto_running
		auto_run_speed = RUSH_SPEED if is_auto_running else WALK_SPEED
		auto_run_animation = "rush" if is_auto_running else "idle"

	if Input.is_action_just_pressed("move-jump") and not is_jumping:
		is_jumping = true
		sprite.play("jump")
		await get_tree().create_timer(0.5).timeout
		is_jumping = false

func handle_movement(delta):
	if is_dying:
		return

	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("move-right"):
		input_vector.x += 1
	elif Input.is_action_pressed("move-left"):
		input_vector.x -= 1

	if Input.is_action_pressed("move-up"):
		input_vector.y -= 1
	elif Input.is_action_pressed("move-down"):
		input_vector.y += 1

	if is_auto_running:
		if Input.is_action_pressed("move-left"):
			direction.x = -1
		elif Input.is_action_pressed("move-right"):
			direction.x = 1
		input_vector.x = direction.x

	var speed = auto_run_speed if is_auto_running else WALK_SPEED

	velocity = input_vector.normalized() * speed
	position += velocity * delta

	if input_vector.x != 0:
		sprite.flip_h = input_vector.x < 0

func handle_animation():
	if is_dying:
		return

	if is_damaging:
		return  # <--- stop other animations habang damage

	if is_jumping:
		if sprite.animation != "jump":
			sprite.play("jump")
	elif velocity.length() > 0:
		if is_auto_running:
			if sprite.animation != auto_run_animation:
				sprite.play(auto_run_animation)
		else:
			if sprite.animation != "idle":
				sprite.play("idle")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")

func death():
	if not is_dying:
		print("dead")
		is_dying = true
		is_dead = true
		sprite.play("die")

func damage():
	if not is_dead and not is_dying and not is_damaging:
		print("damage")
		is_damaging = true
		sprite.play("damage")
		await get_tree().create_timer(0.5).timeout  # adjust mo kung gaano katagal ang damage animation mo
		is_damaging = false
