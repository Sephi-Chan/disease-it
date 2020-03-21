# Disease it

![Disease it](https://img.itch.zone/aW1hZ2UvNTg1ODI5LzMxMTEwNDMucG5n/original/57JEPx.png)

Vous incarnez une maladie sur une île. Votre objectif : contaminer le plus d'humains et rejoindre le port pour vous déverser sur le monde !

Attention, vos adversaires essaieront de vous prendre de vitesse ! Mettez-leur des bâtons dans les roues et ne perdez pas trop de temps !



## Comment jouer ?

Le jeu se joue dans un navigateur (moderne), en se rendant à cette adresse. 

http://disease-it.jeuweb.org/

Vous n'avez qu'à créer une partie et partager le lien avec des amis. :) 



## Règles de jeu

Le plateau de jeu est composé de cases portant chacune un nombre. 

Une fois la partie démarrée, l'un des joueurs lance 4 dés pour tout le monde. Chaque joueur doit alors se déplacer vers une case adjacente à condition qu'elle porte un nombre indiqué par l'un des dés. Si aucune case n'est éligible, le joueur perd un point de mort ! Une fois que tout le monde s'est déplacé (ou a perdu un point de vie), l'opération recommence : un joueur jette les dés et chacun choisit la case sur laquelle se déplacer ou perd un point de vie.

Pour marquer des points, il faut contaminer des humains en se déplaçant sur les cases accueillant des bâtiments (s'y rendre plusieurs fois au cours de la partie ne rapporte rien de plus). Chaque bâtiment contaminé rapporte 3 points. Veillez tout de même à rejoindre le port rapidement, avant d'être à court de points de mort ! Un bonus de points de victoire est octroyé selon l'ordre d'arrivée : 6 pour le premier, 4 pour le second, 2 pour le troisième et rien pour le dernier ! Chacun reçoit le bonus en cas d'arrivée simultanée.

Le partie s'achève quand chaque joueur a atteint le port ou a perdu tous ses points de mort. Les scores sont comparés pour désigner le vainqueur. Certaines parties s'achèvent sans aucun vainqueur.



À propos du développement

Le serveur du jeu est développé avec le langage Elixir, en suivant une architecture CQRS/ES. Le framework Phoenix est utilisé pour la partie Web et les communications entre les clients et le serveur par WebSocket.

Le client est une application Web écrite en HTML/CSS/Javascript à l'aide de React. 
