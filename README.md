# Diggers

## Start the database

pg_ctl -D /usr/local/var/postgres start

mix do event_store.drop, event_store.create, event_store.init



Ce document liste les interactions possible avec le système.

- PlayerOpensLobby : un joueur crée un lobby, il en est le chef et premier membre.
- PlayerJoinsLobby : un joueur (absent du lobby) rejoint le lobby donné.
- PlayerLeavesLobby : un joueur (présent dans le lobby) quitte le lobby. Un lobby est fermé quand son dernier joueur le quitte. Si le chef du lobby le quitte, le deuxième joueur entré est désigné chef.
- PlayerStartsGame : le chef du lobby démarre la partie (s'il y a 2 membres au moins).

Au début de la phase de génération du terrain, un plateau de jeu est créé pour chaque joueur de la partie.
Chaque plateau de jeu est initialement identique : toutes les cases portent au moins un nombre de 1 à 6 et certaines cases contiennent un diamant.
Chaque joueur reçoit alors un plateau duquel il désactive 3 cases.
L'entrée et la sortie de la mine ne peuvent pas être désactivées. Une case adjacente à une case désactivée ne peut pas être désactivée.
Quand chaque joueur a désactivé 3 cases, chaque joueur reçoit un autre plateau pour y désactiver 3 autres cases. L'opération recommence jusqu'à ce que chaque joueur ait désactivé 3 cases sur tous les plateaux.

- PlayerDisablesTile : un joueur désactive une case (active et non adjacente à une case désactivée) d'un plateau s'il n'a pas déjà désactivé 3 cases de ce plateau.

Une fois cette phase de génération du terrain terminée, la premier tour de la phase de jeu commence. Les joueurs sont placés sur la case de départ. 4 dés à 6 faces sont lancés.
Chaque joueur doit alors choisir une case adjacente à celle sur laquelle il se trouve et qui porte le nombre montré par l'un des dés. Si aucune case ne correspond, le joueur ne bouge pas et perd un point d'oxygène.
Quand un joueur n'a plus de points d'oxygène, il perd la partie.
Quand chaque joueur a choisi une action (ou n'a pas pu le faire), la partie s'achève si au moins un joueur a atteint la case d'arrivée ; dans le cas contraire, le tour suivant commence.
Quand un joueur atteint la case d'arrivée, il est retiré de la partie et ses points sont comptés.
La partie s'arrête quand tous les joueurs sont sortis ou tous éliminés ou bien qu'il ne reste plus qu'un joueur encore en jeu.
A chaque fois qu'un joueur atteint la case d'arrivée, un dé de moins est lancé au début de chaque tour (jusqu'à un minimum de 1 dé).

- PlayerMoves : un joueur se déplace de sa case actuelle vers une case adjacente qui porte le nombre affiché par un des dés.



Pitch :
C'est un jeu qui se joue de 2 à 4, et inspiré d'un jeu de plateau et qui se joue dans le navigateur.
On y incarne une maladie (le thème de la jam, c'est "Contamination"). On part tous du navire échoué (en bas à gauche) et il faut rejoindre le port (en haut à droite). Il faut passer par le plus de campements humains possible.
En début de partie, chaque joueur désactive quelques cases sur le plateau de jeux des camarades, et les plateaux sont distribués aléatoirement et la partie commence réellement.
Ensuite, à chaque tour quatre dés sont lancés, et tu ne peux aller que sur une case adjacente à la tienne et qui porte un numéro donné par les dés : si tu ne peux pas, ta maladie perd en létalité (c'est une façon de perdre). Les premiers arrivés au port sont récompensés et enlèvent un dé (du coup ça met la pression à ceux qui n'ont pas fini puisqu'ils ont plus de chance de ne pas pouvoir se déplacer de case en case et donc perdre).
