extends Sprite2D

# Cell Phone Script
# this will handle the cell phone transition cutscene functions

@export var cellphone_text : CellPhoneText

# Logic for executing picked up cutscene, triggered from the player script
func picked_up():
	$CellPhoneAnimation.play("cellphone_initialize")
	await $CellPhoneAnimation.animation_finished
	

func unlock_vertical_looking():
	cellphone_text.set_cellphonetext("Unlocking... \nVertical Look Direction")
	await get_tree().create_timer(.4).timeout
	g.y_look_unlocked = true

func unlock_jumping():
	cellphone_text.set_cellphonetext("Unlocking... \nJumping")
	await get_tree().create_timer(.4).timeout
	g.jumping_unlocked = true

func unlock_shotgun_jump():
	cellphone_text.set_cellphonetext("Unlocking... \nShotgun Jump")
	await get_tree().create_timer(.4).timeout
	g.recoil_unlocked = true

func unlock_world_switch():
	cellphone_text.set_cellphonetext("Unlocking... \n&A gentler world.")
	await get_tree().create_timer(4).timeout
	Music.play_track("cuddly_descent")
	g.world_switch()
	g.low_gravity = true
	await get_tree().create_timer(5.0).timeout
	g.world_switch_unlocked = true
	cellphone_text.set_not_visible()

	await get_tree().create_timer(12.0).timeout
	g.low_gravity = false
	
