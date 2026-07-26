extends StaticBody3D

var turn_speed : float = 180

func _physics_process(delta: float) -> void:
	%Inner.rotate_x(deg_to_rad(turn_speed) * delta)
	%Middle.rotate_y(deg_to_rad(turn_speed) * delta / 2)
	%Outer.rotate_z(deg_to_rad(turn_speed) * delta / 3)
