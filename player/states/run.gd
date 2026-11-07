class_name PlayerStateRun extends PlayerState


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
	player.animation_player.play("run")
	print("enter",  name)
	pass
	
	
## Appelée quand la machine à états quitte cet état, juste avant le enter()
## de l'état suivant. À utiliser pour arrêter les animations, relâcher les
## flags de l'état sortant, remettre la vélocité à zéro, etc.
func exit() -> void:
	print("exit",  name)
	pass
	
## Appelée à chaque événement d'entrée non consommé par le joueur.
## Le paramètre _event contient l'InputEvent qui a déclenché l'appel.
## Renvoie l'état dans lequel continuer :
##   - self (ou next_state inchangé) pour rester dans cet état ;
##   - un autre PlayerState pour déclencher une transition.
## Attention : next_state vaut null tant qu'aucun état ne l'a renseigné.
func handle_input( _event : InputEvent ) -> PlayerState :
	if _event.is_action_pressed("jump") :
		return jump
	return next_state
	
## Appelée à chaque frame par la machine à états (depuis _physics_process).
## delta est le temps écoulé depuis la frame précédente, en secondes : à
## utiliser pour tout ce qui est dépendant du temps (vitesse, gravité, timers).
## Renvoie l'état dans lequel continuer (self pour rester dans cet état).
func process(delta: float) -> PlayerState:
	if player.direction.x == 0 :
		return idle
	elif player.direction.y > 0.5 :
		return crouch
	return  next_state
	
	
## Appelée à chaque frame de physique (depuis _physics_process du joueur), donc
## à pas de temps fixe : c'est ici qu'on lit les entrées et qu'on déplace un
## CharacterBody2D (vélocité, gravité, move_and_slide()).
## Renvoie l'état dans lequel continuer (self pour rester dans cet état).
func physics_process(delta: float) -> PlayerState:
	player.velocity.x = player.direction.x * player.move_speed
	if player.is_on_floor() == false : 
		return fall
	return  next_state
