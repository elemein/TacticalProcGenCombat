extends Spatial

func set_text(new_text):
	$Viewport/Label.set_text(str(new_text))
	
	translation.y += 1
	
	var tween_time = 0.75
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	$Tween.connect("tween_completed", self, "_on_timer_timeout")
	$Tween.interpolate_property(self, "translation", translation, 
		translation + Vector3(0,(4 + (rng.randf_range(0,0.75))),
		(rng.randf_range(0,1.5)-0.75)), tween_time, 
		Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()

func _on_timer_timeout(_tween_object, _tween_node_path):
	get_parent().remove_child(self)
	self.queue_free()
