extends Spatial

# RED DAMAGE COLOR: Color(0.45098, 0, 0)
# GREEN HEAL COLOR: Color(0.168627, 0.698039, 0)

func create_notif(notif_text, notif_type):
	$Viewport/Label.set_text(str(notif_text))
	
	translation.y += 1
	
	match notif_type:
		'damage': damage_notif(false)
		'crit damage' : damage_notif(true)
		'heal': heal_notif()
		'ready': ready_notif()

func ready_notif():
	$Viewport/Label.set("custom_colors/font_color", Color(0.13, 0.55, 0.13))
	
	var tween_time = 0.5
	
	var _result = $Tween.connect("tween_completed", self, "_on_tween_complete")
	$Tween.interpolate_property(self, "translation", translation, 
		translation + Vector3(0,3.5,0), tween_time, 
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func heal_notif():
	$Viewport/Label.set("custom_colors/font_color", Color(0.168627, 0.698039, 0))
	
	var tween_time = 0.75
	
	var _result = $Tween.connect("tween_completed", self, "_on_tween_complete")
	$Tween.interpolate_property(self, "translation", translation, 
		translation + Vector3(0,3.5,0), tween_time, 
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.start()

func damage_notif(is_crit):
	if is_crit == false: $Viewport/Label.set("custom_colors/font_color", Color(0.45098, 0, 0))
	elif is_crit == true: $Viewport/Label.set("custom_colors/font_color", Color(0.854902, 0.745098, 0))
	
	var tween_time = 0.75
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var _result = $Tween.connect("tween_completed", self, "_on_tween_complete")
	$Tween.interpolate_property(self, "translation", translation, 
		translation + Vector3(0,(4 + (rng.randf_range(0,0.75))),
		(rng.randf_range(0,1.5)-0.75)), tween_time, 
		Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()

func _on_tween_complete(_tween_object, _tween_node_path):
	get_parent().remove_child(self)
	self.queue_free()
