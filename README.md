Intro
-----

When I was little, I loved puzzles; I also loved Pokémon. The [Ice Path](http://bulbapedia.bulbagarden.net/wiki/Ice_Path) of Pokémon Gold and Silver presented a new type of puzzle, and a brief but exciting challenge, which stuck with me. Recently I tried to create an "ice maze" of my own, to share my fond memory with a friend (and promote the slick idea), but I became frustrated with many failed attempts on paper, therefore decided to write this program to generate and analyse ice mazes. Also this seemed a timely opportunity to learn and practise programming in [Go](http://golang.org/).

Seems that a great ice maze would:

* have few (or only one) possible paths to the exit, each satisfying the following criteria
* have many steps along the exit path, with no shortcuts
* have many forks in the exit path
* have many fall-off points, dead-ends, and traps along the exit path (the final point of a trap should be several steps off the exit path, so that players may wander into the trap without foreseeing it)
* have lots of open space (so that possible paths are not as visible as in usual mazes of which the walls are all drawn in)
* have distractions and confusing clutter (e.g. promising spots impossible to reach, like pots of gold)
* be frustrating ("what am I not seeing?!")

Features
--------

* server designed to run on [Google App Engine](https://developers.google.com/appengine/)
* web-based user interface
* create new mazes, resize
* user manually designs or modifies mazes in browser
* server analyses mazes for possible paths, traps, solutions, and displays these in the browser so that user can see the paths, and adjust and improve the maze
* sever generates random mazes to meet user-provided criteria
* set certain tiles as "locked" so that server won't modify those tiles on further randomization
* "play" mode where user directs an avatar (via keyboard input) through the maze in the browser

Wishlist
--------

* drop-down to load predefined mazes (e.g. original Pokémon GS Ice Path)
* keep "recent mazes" or "saved mazes" in local browser storage
* drag-and-drop to reposition entrance/exit
* animation of entrance/exit orientation-rotation when dragged to a new side
* draw maze to a canvas instead of a grid of buttons
* alternative tilesets (e.g. original Pokémon GS/Crystal tilesets)
* isometric display option
