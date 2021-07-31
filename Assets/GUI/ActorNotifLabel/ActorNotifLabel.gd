extends Spatial

# RED DAMAGE COLOR: Color(0.45098, 0, 0)
# GREEN HEAL COLOR: Color(0.168627, 0.698039, 0)

func create_notif(notif_text, notif_type):
	$Viewport/Label.set_text(str(notif_text))
	
	translation.y += 1
	
	match notif_type:
		'damage': damage_notif()
		'heal': heal_notif()

func heal_notif():
	$Viewport/Label.set("custom_colors/font_color", Color(0.168627, 0.698039, 0))
	
	var tween_time = 0.75
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	$Tween.connect("tween_completed", self, "_on_tween_complete")
	$Tween.interpolate_property(self, "translation", translation, 
		translation + Vector3(0,3.5,0), tween_time, 
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.start()

func damage_notif():
	$Viewport/Label.set("custom_colors/font_color", Color(0.45098, 0, 0))
	
	var tween_time = 0.75
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	$Tween.connect("tween_completed", self, "_on_tween_complete")
	$Tween.interpolate_property(self, "translation", translation, 
		translation + Vector3(0,(4 + (rng.randf_range(0,0.75))),
		(rng.randf_range(0,1.5)-0.75)), tween_time, 
		Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()

func _on_tween_complete(_tween_object, _tween_node_path):
	get_parent().remove_child(self)
	self.queue_free()
