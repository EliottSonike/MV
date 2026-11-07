class_name PlayerStateFall extends PlayerState

@export var fall_gravity_multiplier : float = 1.1
@export var coyote_time : float = 0.4
@export var jump_buffer_time : float = 0.2


var coyote_timer : float = 0
var buffer_timer : float = 0

## Initialisation de l'état : appelée une seule fois, au démarrage,
## quand la machine à états déclare tous ses états.
## Sert à mettre en cache les références stables (le joueur, ses sous-nœuds,
## les états voisins...) sans les relire à chaque frame.
func init() -> void:
	print("init!",  name)
	pass


## Appelée quand la machine à états entre dans cet état.
## À utiliser pour réinitialiser les données de l'état (compteurs, timers)
## et lancer l'animation correspondante, ex. animationsprite.play("run").
func enter() -> void:
	player.animation_player.play("jump")
	player.animation_player.pause()
	player.gravity_multiplier = fall_gravity_multiplier
	if player.previous_state == jump :
		coyote_timer = 0
	else :
		coyote_timer = coyote_time
	pass
	
	
## Appelée quand la machine à états quitte cet état, juste avant le enter()
## de l'état suivant. À utiliser pour arrêter les animations, relâcher les
## flags de l'état sortant, remettre la vélocité à zéro, etc.
func exit() -> void:
	player.gravity_multiplier = 1.0
	buffer_timer = 0	
	pass
	
## Appelée à chaque événement d'entrée non consommé par le joueur.
## Le paramètre _event contient l'InputEvent qui a déclenché l'appel.
## Renvoie l'état dans lequel continuer :
##   - self (ou next_state inchangé) pour rester dans cet état ;
##   - un autre PlayerState pour déclencher une transition.
## Attention : next_state vaut null tant qu'aucun état ne l'a renseigné.
func handle_input( _event : InputEvent ) -> PlayerState :
	
	if _event.is_action_pressed("jump") :
		if coyote_timer > 0 :
			return jump
		else :
			buffer_timer = jump_buffer_time
	return next_state
	
## Appelée à chaque frame par la machine à états (depuis _physics_process).
## delta est le temps écoulé depuis la frame précédente, en secondes : à
## utiliser pour tout ce qui est dépendant du temps (vitesse, gravité, timers).
## Renvoie l'état dans lequel continuer (self pour rester dans cet état).
func process(delta: float) -> PlayerState:
	coyote_timer -= delta
	buffer_timer -= delta
	set_jump_frame()
	return  next_state
	
	
## Appelée à chaque frame de physique (depuis _physics_process du joueur), donc
## à pas de temps fixe : c'est ici qu'on lit les entrées et qu'on déplace un
## CharacterBody2D (vélocité, gravité, move_and_slide()).
## Renvoie l'état dans lequel continuer (self pour rester dans cet état).
func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = player.direction.x * player.move_speed*0.7
	if player.is_on_floor() : 
		if buffer_timer > 0 :
			return jump
		return idle
	return  next_state
	
func set_jump_frame() -> void :
	var frame : float = remap(player.velocity.y, 0.0, player.max_fall_velocity, 0.5, 1.0)
	player.animation_player.seek(frame, true)
	pass
