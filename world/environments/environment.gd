extends WorldEnvironment

# World Environment Script

# This will switch the world environment between the demon and cuddly environments

@export var demon_environment : Environment
@export var cuddly_environment: Environment

func _ready():
	g.world_toggled.connect(switch_environment)
	switch_environment()


func switch_environment():
	if g.cuddly_world == false:
		environment = demon_environment
	else:
		environment = cuddly_environment
