extends Spatial

onready var notif_text = $Viewport/Label
onready var tween = $Tween

# RED DAMAGE COLOR: Color(0.45098, 0, 0)
# GREEN HEAL COLOR: Color(0.168627, 0.698039, 0)

func create_notif(text, type):
	self.notif_text.set_text(str(text))
	
	match type:
		'damage': damage_notif(false)
		'crit damage' : damage_notif(true)
		'heal': heal_notif()
		'interrupt': interrupt_notif()

func interrupt_notif():
	self.notif_text.set("custom_colors/font_color", Color(0.45098, 0, 0))
	
	var tween_time = 0.5
	
	var _result = self.tween.connect("tween_completed", self, "_on_tween_complete")
	self.tween.interpolate_property(self, "translation", translation, 
		translation + Vector3(0,4,0), tween_time, 
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	self.tween.start()

func heal_notif():
	self.notif_text.set("custom_colors/font_color", Color(0.168627, 0.698039, 0))
	
	var tween_time = 0.75
	
	var _result = self.tween.connect("tween_completed", self, "_on_tween_complete")
	self.tween.interpolate_property(self, "translation", translation, 
		translation + Vector3(0,3.5,0), tween_time, 
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	self.tween.start()

func damage_notif(is_crit):
	if is_crit == false: self.notif_text.set("custom_colors/font_color", Color(0.45098, 0, 0))
	elif is_crit == true: self.notif_text.set("custom_colors/font_color", Color(0.854902, 0.745098, 0))
	
	var tween_time = 0.75
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var _result = self.tween.connect("tween_completed", self, "_on_tween_complete")
	self.tween.interpolate_property(self, "translation", translation, 
		translation + Vector3(0,(4 + (rng.randf_range(0,0.75))),
		(rng.randf_range(0,1.5)-0.75)), tween_time, 
		Tween.TRANS_QUART, Tween.EASE_OUT)
	self.tween.start()

func _on_tween_complete(_tween_object, _tween_node_path):
	get_parent().remove_child(self)
	self.queue_free()
