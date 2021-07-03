extends MarginContainer

onready var amount = $Amount
onready var stat = $Stat

var amount_text = 0
var stat_text = ''

var pos_x = 0 setget set_pos_x
var pos_y = 20 setget set_pos_y
var marg_top = 20 setget set_marg_top
var marg_bot = 35 setget set_marg_top

# Called when the node enters the scene tree for the first time.
func _ready():
	force_position()
	set_amount(amount_text)
	set_stat(stat_text)

func set_amount(value):
	amount_text = value
	if amount != null:
		amount.text = str(value)
	
func set_stat(value):
	stat_text = value
	if stat != null:
		stat.text = value

func force_position():
	if amount != null and stat != null:
		# Godot is really being a pain and keeps resetting these values so need to force them here
		amount.rect_position.x = pos_x
		amount.rect_position.y = pos_y
		amount.margin_top = marg_top
		amount.margin_bottom = marg_bot
		amount.rect_size.x = 75
		
		stat.rect_position.x = pos_x + 75
		stat.rect_position.y = pos_y
		stat.margin_top = marg_top
		stat.margin_bottom = marg_bot
		stat.rect_size.x = 75

func set_pos_x(value):
	pos_x = value
	force_position()
	
func set_pos_y(value):
	pos_y = value
	force_position()
	
func set_marg_top(value):
	marg_top = value
	force_position()
	
func set_marg_bot(value):
	marg_bot = value
	force_position()
