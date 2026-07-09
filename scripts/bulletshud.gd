extends HBoxContainer

func _on_main_scene_bullet_used(ammoinfo):
	var total_bullets = ammoinfo.count(1)
	for number in range(6):
		var icon = get_child(number)
		if number < total_bullets:
			icon.modulate = Color(1, 1, 1)
		else:
			icon.modulate = Color(0, 0, 0)
