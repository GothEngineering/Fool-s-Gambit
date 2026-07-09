extends Node2D

# Nodes go here
@onready var revolver_cylinder: Sprite2D = $RevolverCylinder

#========= HUD ============
#Remember, rounds_counter is the node and high score/kill count are children of it
@onready var darkness_my_friend: ColorRect = $CanvasLayer/DarknessMyFriend
@onready var grit: Label = $CanvasLayer/Grit
@onready var retry_button: Button = $CanvasLayer/DarknessMyFriend/RetryButton
@onready var rounds_counter: Node = %RoundsCounter
@onready var high_score: Label = $"RoundsCounter/High Score"
@onready var kill_count: Label = $"RoundsCounter/Kill Count"
@onready var blood_bank: Node2D = $BloodBank
@onready var bullets_container: HBoxContainer = $CanvasLayer/BulletsContainer
@onready var instructions: Label = $CanvasLayer/Instructions
@onready var one_more_game: Label = $CanvasLayer/OneMoreGame
@onready var gore: Label = $CanvasLayer/Gore

#======== SFX and timers ========
@onready var bang___: AudioStreamPlayer = $"BANG!!!"
@onready var empty_chamber: AudioStreamPlayer = $EmptyChamber
@onready var short_spin: AudioStreamPlayer = $ShortSpin
@onready var long_spin: AudioStreamPlayer = $LongSpin
@onready var spin_timer: Timer = $SpinTimer
@onready var hesitant: AudioStreamPlayer = $Hesitant
@onready var hesitant_wait: Timer = $HesitantWait


@export var blood_splatter_scene: PackedScene

signal bullet_used

# The logic
var chamber: int = 0
var bullets_in_chamber = [0, 0, 0, 1, 0, 0]
var chamber_rotation: float = 0.0 
var loaded_bullets = bullets_in_chamber.count(1)

# States
var are_you_dead = false
var nsfw_mode = false
var pulling_the_trigger = false
var already_shaking = false

var hesitation = 0

var blood_splatters = [
	preload("res://assets/blood_splat_1.png"),
	preload("res://assets/blood_splat_3.png"),
]

func _ready():
	bullets_in_chamber.shuffle()
	print(bullets_in_chamber)
	bullet_used.emit(bullets_in_chamber)
	dissapear_instructions(instructions)

func _process(delta: float):
	if are_you_dead == true:
		return

	if Input.is_action_just_pressed("LeftMouse"):
		spin_the_cylinder()

	if Input.is_action_just_pressed("Debug Mode"):
		print("Current chamber: ", chamber)
		print("Current chamber rotation: ", chamber_rotation)
		print("The bullets in the chamber: ", bullets_in_chamber)
		print("Current hesitation: ", hesitation)  

	if Input.is_action_just_pressed("R key"):
		if pulling_the_trigger:
			return
		var is_hole_empty = false
		for hole in range(bullets_in_chamber.size()):
			if bullets_in_chamber[hole] == 0:
				bullets_in_chamber[hole] = 1
				is_hole_empty = true
				bullet_used.emit(bullets_in_chamber)
				break
		if is_hole_empty == false:
			print("The revolver is full. It weighs heavily.")

#Shooting system, try to resize this part as much as possible
	if Input.is_action_just_pressed("RightMouse") and not pulling_the_trigger:
		pulling_the_trigger = true
		await fear()
		shake(high_score, 0.2, 4.0 + rounds_counter.rounds_survived)
		if bullets_in_chamber[chamber] > 0:
			bullets_in_chamber[chamber] = 0
			bang___.play()
			deathdeathdeath()
		else:
			empty_chamber.play()
			rounds_counter.add_score()
		pulling_the_trigger = false
		spin_the_cylinder()

	if Input.is_action_just_pressed("Space bar"):
		spin_the_cylinder(randi_range(10, 15)) #Adjust this randomizer to fit the SFX, and also buff it

	if Input.is_action_just_pressed("B stands for Blood"):
		nsfw_mode = !nsfw_mode
		if nsfw_mode == true:
			gore.text = """Blood Splatters: 
				ON"""
			gore.modulate = Color.RED
			blood_bank.show()
		else:
			gore.text = """Blood Splatters: 
				Off"""
			gore.modulate = Color.WHITE
			blood_bank.hide()

	revolver_cylinder.rotation_degrees = lerp(revolver_cylinder.rotation_degrees, chamber_rotation, 0.1)

func dissapear_instructions(object):
	var instructionsfadeout = create_tween()
	instructionsfadeout.tween_property(object, "modulate:a", 0.0, 20.0)
	instructionsfadeout.tween_callback(object.hide)

func spin_the_cylinder(number_of_spins = 1):
	if pulling_the_trigger:
		return
	chamber += number_of_spins
	chamber = chamber % 6
	chamber_rotation += 60 * number_of_spins
	bullet_used.emit(bullets_in_chamber)
	spin_timer.start()
	if number_of_spins > 1:
		long_spin.play()
	else: 
		short_spin.play()
		short_spin.pitch_scale = randf_range(1.0, 1.2)

func deathdeathdeath():
	darkness_my_friend.show()
	bullets_container.hide()
	long_spin.stop()
	are_you_dead = true
	await get_tree().create_timer(5.0).timeout
	grit.modulate.a = 0
	grit.show()
	var animacioninsana = create_tween()
	animacioninsana.tween_property(grit, "modulate:a", 1.0, 3.5)
	retry_button.modulate.a = 0
	retry_button.show()
	animacioninsana.tween_property(retry_button, "modulate:a", 1.0, 2.0)
	rounds_counter.add_kill()
	rounds_counter.reset_score()

func fear():
	hesitation += 1 
	if hesitation < 10:
		hesitant.play()
		hesitant_wait.start()
		await hesitant_wait.timeout

func keep_playing():
	are_you_dead = false
	darkness_my_friend.hide()
	grit.hide()
	retry_button.hide()
	high_score.show()
	kill_count.show()
	bullets_container.show()
	bullet_used.emit(bullets_in_chamber)
	one_more_game.show()
	dissapear_instructions(one_more_game)
	hesitation = 0
	if nsfw_mode == true:
		do_blood_splatters()

func shake(target, duration = 0.2, intensity = 4.0):
	var default_position = target.position
	if already_shaking:
		return
	already_shaking = true
	while duration > 0:
		target.position = default_position + Vector2(randf_range(-intensity, intensity),
		randf_range(-intensity, intensity))
		await get_tree().create_timer(0.01).timeout
		duration -= 0.01
	target.position = default_position
	already_shaking = false


func do_blood_splatters():
	var yourblood = blood_splatter_scene.instantiate()
	blood_bank.add_child(yourblood)
	yourblood.position = Vector2(randf_range(-500, 500), randf_range(-500, 500))
	yourblood.scale = Vector2(0.4, 0.4)

func _on_retry_button_pressed():
	keep_playing()

func _on_spin_timer_timeout():
	$LongSpin.stop()
