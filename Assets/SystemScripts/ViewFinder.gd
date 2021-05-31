# So how this works is that to find the view, we first draw a box of all the further viewable points
# away from the actor determined by view range.
# We then use Bressenham's Algo to draw a line of points from the actor to that endpoint.
# If there is a collision with a wall, we stop and don't include that point.
extends Node

const VIEW_RANGE = 4

onready var map = get_node("/root/World/Map")

var pos_x = 0
var pos_z = 0
var pos = [0,0]

var vision_boundaries = []
var visible_tiles = []

func reset_vars():
	vision_boundaries = []
	visible_tiles = []

func find_view_field(x, z):
	reset_vars()
	
	pos_x = x
	pos_z = z
	pos = [x, z]
#	print(pos)
	
	form_vision_boundaries()

	for endpoint in vision_boundaries:
		var tiles_to_add = draw_line([pos_x, pos_z], endpoint)
		
		for tile in tiles_to_add:
			if (tile in visible_tiles) == false:
				visible_tiles.append(tile)

#	print('visible tiles')
#	print(visible_tiles)
	return visible_tiles

func draw_line(p0, p1): # I don't fully understand this. I hope to learn it. - SS
	# delta = change of
	var points = []
	var delta_x = abs(p1[0] - p0[0]) # I understand up to here.
	var delta_y = -abs(p1[1] - p0[1])
	var err = delta_x + delta_y
	var e2 = 2 * err
	var next_x = 1 if p0[0] < p1[0] else -1
	var next_y = 1 if p0[1] < p1[1] else -1
	while true:
		points.append([p0[0], p0[1]]) # Adds tile to line.
		
		if map.is_tile_wall(p0[0], p0[1]) == true: break # Checks collision with wall
		if p0[0] == p1[0] and p0[1] == p1[1]: break # If at endpoint, stop.
			
		e2 = 2 * err
		if e2 >= delta_y:
			err += delta_y
			p0[0] += next_x
		if e2 <= delta_x:
			err += delta_x
			p0[1] += next_y
	return points


func form_vision_boundaries():
	# top and bottom
	for x in [-VIEW_RANGE, VIEW_RANGE]:
		for z in range(-VIEW_RANGE, VIEW_RANGE +1):
			vision_boundaries.append([pos_x + x, pos_z + z])
	
	# left and right
	for z in [-VIEW_RANGE, VIEW_RANGE]:
		for x in range(-VIEW_RANGE, VIEW_RANGE +1):
			if ([pos_x + x, pos_z + z] in vision_boundaries) == false :
				vision_boundaries.append([pos_x + x, pos_z + z])
