extends Sprite2D

# Cell Phone Script
# this will handle the cell phone transition cutscene functions

# Logic for executing picked up cutscene, triggered from the player script
func picked_up():
	$CellPhoneAnimation.play("cellphone_initialize")
	await $CellPhoneAnimation.animation_finished
		
	g.y_look_unlocked = true
	g.recoil_unlocked = true
	g.world_switch_unlocked = true
	g.world_switch()
