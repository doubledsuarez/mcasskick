extends Sprite2D

# Cell Phone Script
# this will handle the cell phone transition cutscene functions

@export var cellphone_text : CellPhoneText


var tutorial_mode := false

var learned_world_toggle := false
var started_learning_world_toggle := false
var learned_shotgun_jump := false
var started_learning_shotgun_jump := false

# Logic for executing picked up cutscene, triggered from the player script
func picked_up():
	$CellPhoneAnimation.play("cellphone_initialize")
	await $CellPhoneAnimation.animation_finished

func _ready():
	await get_tree().create_timer(0.3).timeout
	g.world_toggled.connect(learn_world_toggle)
	g.player.shooting.connect(learn_shotgun_jump)

func learn_world_toggle():
	if tutorial_mode:
		await get_tree().create_timer(2.0).timeout
		learned_world_toggle = true

func learn_shotgun_jump():
	if tutorial_mode:
		if g.player.is_on_floor() == false:
			await get_tree().create_timer(2.0).timeout
			learned_shotgun_jump = true
			cellphone_text.set_not_visible()
		

func _physics_process(delta):
	if tutorial_mode:
		if learned_world_toggle == false:
			if started_learning_world_toggle == false:
				started_learning_world_toggle = true
				cellphone_text.set_cellphonetext("Press right click to toggle between worlds!")
		elif learned_shotgun_jump == false:
			if started_learning_shotgun_jump == false:
				started_learning_shotgun_jump = true
				cellphone_text.set_cellphonetext("Shoot while jumping to shotgun jump!")

	

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

	await get_tree().create_timer(6.0).timeout
	g.low_gravity = false
	
	await get_tree().create_timer(4.0).timeout
	
	tutorial_mode = true
	
