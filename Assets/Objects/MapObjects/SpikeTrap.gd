extends GameObj

var trap_damage = 33

var sprung = false

var minimap_icon = null

var identity = {"Category": "MapObject", "CategoryType": "Trap", 
				"Identifier": "Spike Trap", 'Map ID': null, 
				'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity): pass

func activate_trap(tile_objects):
	for object in tile_objects:
		if object.get_id()['CategoryType'] == 'Player':
			if sprung == false: # only spring if not already sprung
				Server.object_action_event(object_identity, {"Command Type": "Spawn On Map"})
				sprung = true
				visible = true
				
				var damage_instance = {"Amount": trap_damage, "Crit": false, \
										"Attacker": self}
				
				object.take_damage(damage_instance)
				
				var _result = $Tween.connect("tween_completed", self, "_on_tween_complete")
				$Tween.interpolate_property(self, "translation", translation, 
					translation + Vector3(0,1,0), 1, 
					Tween.TRANS_ELASTIC, Tween.EASE_OUT)
				$Tween.start()

func _on_tween_complete(_tween_object, _tween_node_path):
	Server.object_action_event(object_identity, {"Command Type": "Remove From Map"})
