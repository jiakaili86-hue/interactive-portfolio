extends Control

@export var strength: int = 0:
	set(value):
		strength = value
		queue_redraw()

@export var slimness: int = 0:
	set(value):
		slimness = value
		queue_redraw()

@export var mood: int = 70:
	set(value):
		mood = value
		queue_redraw()

var bounce_offset: float = 0.0
var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	bounce_offset = sin(_time * 2.2) * 4.0
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5 + Vector2(0.0, bounce_offset)
	var body_width := 86.0 + float(strength) * 1.8 - float(slimness) * 0.8
	var body_height := 112.0 - float(slimness) * 0.9
	var body_color := Color("#fff4f0")
	var cheek_color := Color("#ffb7c8")
	var line_color := Color("#3d3330")
	var accent_color := Color("#f2a6b8")
	var shoe_color := Color("#8ac8b3")

	draw_circle(center + Vector2(-26, -96), 20, body_color)
	draw_circle(center + Vector2(26, -96), 20, body_color)
	draw_circle(center + Vector2(-26, -101), 13, Color("#ffd9e3"))
	draw_circle(center + Vector2(26, -101), 13, Color("#ffd9e3"))
	draw_circle(center + Vector2(0, -66), 48, body_color)
	draw_circle(center + Vector2(0, 26), body_width * 0.5, body_color)
	draw_rect(Rect2(center + Vector2(-body_width * 0.5, -5), Vector2(body_width, body_height)), body_color, true)
	draw_circle(center + Vector2(-body_width * 0.5, 10), 22, body_color)
	draw_circle(center + Vector2(body_width * 0.5, 10), 22, body_color)

	draw_circle(center + Vector2(-16, -72), 4.5, line_color)
	draw_circle(center + Vector2(16, -72), 4.5, line_color)
	draw_arc(center + Vector2(0, -58), 12, 0.15, PI - 0.15, 18, line_color, 2.0)
	draw_circle(center + Vector2(-28, -58), 8, cheek_color)
	draw_circle(center + Vector2(28, -58), 8, cheek_color)

	draw_line(center + Vector2(-body_width * 0.46, -2), center + Vector2(-body_width * 0.72, 42), body_color, 18.0)
	draw_line(center + Vector2(body_width * 0.46, -2), center + Vector2(body_width * 0.72, 42), body_color, 18.0)
	draw_circle(center + Vector2(-body_width * 0.75, 46), 9, body_color)
	draw_circle(center + Vector2(body_width * 0.75, 46), 9, body_color)

	draw_line(center + Vector2(-22, body_height * 0.55), center + Vector2(-34, body_height * 0.82), body_color, 20.0)
	draw_line(center + Vector2(22, body_height * 0.55), center + Vector2(34, body_height * 0.82), body_color, 20.0)
	draw_circle(center + Vector2(-40, body_height * 0.86), 13, shoe_color)
	draw_circle(center + Vector2(40, body_height * 0.86), 13, shoe_color)

	draw_rect(Rect2(center + Vector2(-42, -8), Vector2(84, 42)), accent_color, true)
	draw_line(center + Vector2(-42, 34), center + Vector2(42, 34), Color("#ffffff"), 3.0)
	draw_line(center + Vector2(-42, -8), center + Vector2(42, -8), Color("#ffffff"), 3.0)

	var sparkle_origin := center + Vector2(58, -106)
	draw_line(sparkle_origin + Vector2(-8, 0), sparkle_origin + Vector2(8, 0), Color("#f7c95d"), 3.0)
	draw_line(sparkle_origin + Vector2(0, -8), sparkle_origin + Vector2(0, 8), Color("#f7c95d"), 3.0)
	draw_circle(sparkle_origin, 3.0, Color("#fff2a8"))
