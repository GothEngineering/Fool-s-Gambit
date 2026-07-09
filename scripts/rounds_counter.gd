extends Node

var rounds_survived = 0
var kill_counter = 0
@onready var high_score: Label = $"High Score"
@onready var kill_count: Label = $"Kill Count"

func add_score():
	rounds_survived += 1
	high_score.text = "Times cheated death: " + str(rounds_survived)

func reset_score():
	rounds_survived = 0
	high_score.text = "Times cheated death: 0"

func add_kill():
	kill_counter += 1
	kill_count.text = "Brains blew out: " + str(kill_counter)
