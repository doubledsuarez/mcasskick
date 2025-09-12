extends Area3D

# This is an enemy hitbox that will pass the damage up to the enemy
# This is so the hitbox size can be independant of the actual enemy, and work like in
# doom where the vertical distance doesn't matter.

func take_damage(dmg : int):
	print("Enemy hitbox hit!")
	get_parent()._take_damage(dmg)
